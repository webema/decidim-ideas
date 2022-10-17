# frozen_string_literal: true

module Decidim
  module Ideas
    module Admin
      # A command with all the business logic that updates an
      # existing idea.
      class UpdateIdea < Decidim::Command
        include Decidim::Ideas::AttachmentMethods
        include ::Decidim::AttachmentAttributesMethods

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
            source: form.source,
            hashtag: form.hashtag
          }.merge(
            attachment_attributes(:hero_image)
          )

          add_admin_accessible_attrs(attrs) if current_user.admin?

          attrs
        end

        def add_admin_accessible_attrs(attrs)
          attrs[:state] = form.state if form.state
          attrs[:scoped_type_id] = form.scoped_type_id if form.scoped_type_id
        end
      end
    end
  end
end
