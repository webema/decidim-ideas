# frozen_string_literal: true

module Decidim
  module Ideas
    module Admin
      # A form object used to show the idea data in the administration
      # panel.
      class IdeaForm < Form
        include TranslatableAttributes

        mimic :idea

        translatable_attribute :title, String
        translatable_attribute :description, String
        translatable_attribute :source, String

        attribute :type_id, Integer
        attribute :decidim_scope_id, Integer
        attribute :hashtag, String
        attribute :state, String
        attribute :attachment, AttachmentForm

        attribute :hero_image
        attribute :remove_hero_image, Boolean, default: false

        validates :title, :description, translatable_presence: true
        validate :notify_missing_attachment_if_errored
        validates :hero_image, passthru: { to: Decidim::Idea }

        def map_model(model)
          self.type_id = model.type.id
          self.decidim_scope_id = model.scope&.id
        end

        def state_updatable?
          false
        end

        def scoped_type_id
          return unless type && decidim_scope_id

          type.scopes.find_by(decidim_scopes_id: decidim_scope_id.presence).id
        end

        def idea_type
          @idea_type ||= type_id ? IdeasType.active.find(type_id) : context.idea.type
        end

        def available_scopes
          @available_scopes ||= idea_type.scopes
        end

        alias organization current_organization

        private

        def type
          @type ||= type_id ? Decidim::IdeasType.find(type_id) : context.idea.type
        end

        # This method will add an error to the `attachment` field only if there's
        # any error in any other field. This is needed because when the form has
        # an error, the attachment is lost, so we need a way to inform the user of
        # this problem.
        def notify_missing_attachment_if_errored
          errors.add(:attachment, :needs_to_be_reattached) if errors.any? && attachment.present?
        end
      end
    end
  end
end
