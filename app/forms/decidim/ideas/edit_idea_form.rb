# frozen_string_literal: true

module Decidim
  module Ideas
    # A form object used to collect the data for a new idea.
    class EditIdeaForm < Form
      include TranslatableAttributes
      include AttachmentAttributes

      mimic :idea

      translatable_attribute :title, String
      translatable_attribute :description, String

      attribute :type_id, Integer
      attribute :scope_id, Integer
      attribute :area_id, Integer
      attribute :decidim_user_group_id, Integer
      attribute :state, String
      attribute :attachment, AttachmentForm
      attribute :hashtag, String
      attachments_attribute :photos
      attachments_attribute :documents

      validates :title, :description, translatable_presence: true
      validates :title, length: { maximum: 150 }
      validate :scope_exists
      validate :notify_missing_attachment_if_errored
      validate :trigger_attachment_errors


      def map_model(model)
        self.type_id = model.type.id
        self.scope_id = model.scope&.id
      end

      def state_updatable?
        false
      end

      def scope_id
        return nil if idea_type.only_global_scope_enabled?

        super.presence
      end

      def idea_type
        @idea_type ||= type_id ? IdeasType.find(type_id) : context.idea.type
      end

      def available_scopes
        @available_scopes ||= if idea_type.only_global_scope_enabled?
                                idea_type.scopes.where(scope: nil)
                              else
                                idea_type.scopes
                              end
      end

      def scope
        @scope ||= Scope.find(scope_id) if scope_id.present?
      end

      def scoped_type_id
        return unless type && scope_id

        type.scopes.find_by(decidim_scopes_id: scope_id.presence).id
      end

      private

      def type
        @type ||= type_id ? Decidim::IdeasType.find(type_id) : context.idea.type
      end

      def scope_exists
        return if scope_id.blank?

        errors.add(:scope_id, :invalid) unless IdeasTypeScope.exists?(type: idea_type, scope: scope)
      end

      # This method will add an error to the `attachment` field only if there's
      # any error in any other field. This is needed because when the form has
      # an error, the attachment is lost, so we need a way to inform the user of
      # this problem.
      def notify_missing_attachment_if_errored
        return if attachment.blank?

        errors.add(:attachment, :needs_to_be_reattached) if errors.any?
      end

      def trigger_attachment_errors
        return if attachment.blank?
        return if attachment.valid?

        attachment.errors.each { |error| errors.add(:attachment, error) }

        attachment = Attachment.new(
          attached_to: attachment.try(:attached_to),
          file: attachment.try(:file),
          content_type: attachment.try(:file)&.content_type
        )

        errors.add(:attachment, :file) if !attachment.save && attachment.errors.has_key?(:file)
      end
    end
  end
end
