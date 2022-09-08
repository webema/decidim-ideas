# frozen_string_literal: true

module Decidim
  module Ideas
    module Admin
      # A command with all the business logic that updates an
      # existing idea.
      class UpdateIdea < Decidim::Command
        include Decidim::Ideas::AttachmentMethods

        # Public: Initializes the command.
        #
        # idea - Decidim::Idea
        # form       - A form object with the params.
        def initialize(idea, form, current_user)
          @form = form
          @idea = idea
          @current_user = current_user
          @attached_to = idea
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
            @idea.attachments.destroy_all

            build_attachment
            return broadcast(:invalid) if attachment_invalid?
          end

          @idea = Decidim.traceability.update!(
            idea,
            current_user,
            attributes
          )
          create_attachment if process_attachments?
          # notify_idea_is_extended if @notify_extended
          broadcast(:ok, idea)
        rescue ActiveRecord::RecordInvalid
          broadcast(:invalid, idea)
        end

        private

        attr_reader :form, :idea, :current_user, :attachment

        def attributes
          attrs = {
            title: form.title,
            description: form.description,
            hashtag: form.hashtag
          }

          # if form.signature_type_updatable?
          #   attrs[:signature_type] = form.signature_type
          #   attrs[:scoped_type_id] = form.scoped_type_id if form.scoped_type_id
          # end

          if current_user.admin?
            add_admin_accessible_attrs(attrs)
          # elsif idea.created?
          #   # attrs[:signature_end_date] = form.signature_end_date if idea.custom_signature_end_date_enabled?
          #   attrs[:decidim_area_id] = form.area_id if idea.area_enabled?
          end

          attrs
        end

        def add_admin_accessible_attrs(attrs)
          # attrs[:signature_start_date] = form.signature_start_date
          # attrs[:signature_end_date] = form.signature_end_date
          # attrs[:offline_votes] = form.offline_votes if form.offline_votes
          attrs[:state] = form.state if form.state
          attrs[:decidim_area_id] = form.area_id

          # if idea.published? && form.signature_end_date != idea.signature_end_date &&
          #    form.signature_end_date > idea.signature_end_date
          #   @notify_extended = true
          # end
        end

        # def notify_idea_is_extended
        #   Decidim::EventsManager.publish(
        #     event: "decidim.events.ideas.idea_extended",
        #     event_class: Decidim::Ideas::ExtendIdeaEvent,
        #     resource: idea,
        #     followers: idea.followers - [idea.author]
        #   )
        # end
      end
    end
  end
end
