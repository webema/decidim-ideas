# frozen_string_literal: true

module Decidim
  module Ideas
    # A command with all the business logic that creates a new idea.
    class CreateIdea < Decidim::Command
      include CurrentLocale
      include ::Decidim::MultipleAttachmentsMethods
      include ::Decidim::AttachmentAttributesMethods

      # Public: Initializes the command.
      #
      # form - A form object with the params.
      # current_user - Current user.
      def initialize(form, current_user)
        @form = form
        @current_user = current_user
      end

      # Executes the command. Broadcasts these events:
      #
      # - :ok when everything is valid.
      # - :invalid if the form wasn't valid and we couldn't proceed.
      #
      # Returns nothing.
      def call
        return broadcast(:invalid) if form.invalid?

        if process_attachments?
          build_attachments
          return broadcast(:invalid) if attachments_invalid?
        end

        idea = create_idea

        if idea.persisted?
          broadcast(:ok, idea)
        else
          broadcast(:invalid, idea)
        end
      end

      private

      attr_reader :form, :current_user, :attachment

      # Creates the idea and all default components
      def create_idea
        idea = build_idea
        return idea unless idea.valid?

        idea.transaction do
          idea.save!
          @attached_to = idea
          create_attachments if process_attachments?

          create_components_for(idea)
          send_notification(idea)
          add_author_as_follower(idea)
        end

        idea
      end

      def build_idea
        Idea.new(
          {
            organization: form.current_organization,
            title: { current_locale => form.title },
            description: { current_locale => form.description },
            problem: { current_locale => form.problem },
            current_state: { current_locale => form.current_state },
            info: { current_locale => form.info },
            steps: { current_locale => form.steps },
            boards: { current_locale => form.boards },
            obstacles: { current_locale => form.obstacles },
            time: { current_locale => form.time },
            hours: { current_locale => form.hours },
            cooperations: { current_locale => form.cooperations },
            staff: { current_locale => form.staff },
            working_hours: { current_locale => form.working_hours },
            costs: { current_locale => form.costs },
            source: { current_locale => form.source },
            author: current_user,
            decidim_user_group_id: form.decidim_user_group_id,
            scoped_type: scoped_type,
            state: "created",
            hashtag: form.hashtag
          }.merge(
            attachment_attributes(:hero_image)
          )
        )
      end

      def scoped_type
        IdeasTypeScope.find_by(
          type: form.idea_type,
          scope: form.scope
        )
      end

      def create_components_for(idea)
        Decidim::Ideas.default_components.each do |component_name|
          component = Decidim::Component.create!(
            name: Decidim::Components::Namer.new(idea.organization.available_locales, component_name).i18n_name,
            manifest_name: component_name,
            published_at: Time.current,
            participatory_space: idea
          )

          initialize_pages(component) if component_name == :pages
        end
      end

      def initialize_pages(component)
        Decidim::Pages::CreatePage.call(component) do
          on(:invalid) { raise "Can't create page" }
        end
      end

      def send_notification(idea)
        Decidim::EventsManager.publish(
          event: "decidim.events.ideas.idea_created",
          event_class: Decidim::Ideas::CreateIdeaEvent,
          resource: idea,
          followers: idea.author.followers
        )
      end

      def add_author_as_follower(idea)
        form = Decidim::FollowForm
               .from_params(followable_gid: idea.to_signed_global_id.to_s)
               .with_context(
                 current_organization: idea.organization,
                 current_user: current_user
               )

        Decidim::CreateFollow.new(form, current_user).call
      end
    end
  end
end
