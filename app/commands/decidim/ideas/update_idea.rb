# frozen_string_literal: true

module Decidim
  module Ideas
    # A command with all the business logic that updates an
    # existing idea.
    class UpdateIdea < Decidim::Command
      include ::Decidim::MultipleAttachmentsMethods
      include ::Decidim::GalleryMethods
      include CurrentLocale

      # Public: Initializes the command.
      #
      # idea - Decidim::Idea
      # form - A form object with the params.
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
          build_attachments
          return broadcast(:invalid) if attachments_invalid?
        end

        @idea = Decidim.traceability.update!(
          idea,
          current_user,
          attributes
        )

        photo_cleanup!
        document_cleanup!
        create_attachments if process_attachments?

        broadcast(:ok, idea)
      rescue ActiveRecord::RecordInvalid
        broadcast(:invalid, idea)
      end

      private

      attr_reader :form, :idea, :current_user

      def attributes
        attrs = {
          title: form.title,
          description: form.description,
          hashtag: form.hashtag
        }
        
        if idea.created?
          attrs[:scoped_type_id] = form.scoped_type_id if form.scoped_type_id
        end

        attrs
      end
    end
  end
end
