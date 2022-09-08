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
        attribute :type_id, Integer
        attribute :decidim_scope_id, Integer
        attribute :area_id, Integer
        # attribute :signature_type, String
        # attribute :signature_start_date, Decidim::Attributes::LocalizedDate
        # attribute :signature_end_date, Decidim::Attributes::LocalizedDate
        attribute :hashtag, String
        # attribute :offline_votes, Hash
        attribute :state, String
        attribute :attachment, AttachmentForm

        validates :title, :description, translatable_presence: true
        validates :area, presence: true, if: ->(form) { form.area_id.present? }
        # validates :signature_type, presence: true, if: :signature_type_updatable?
        # validates :signature_start_date, presence: true, if: ->(form) { form.context.idea.published? }
        # validates :signature_end_date, presence: true, if: ->(form) { form.context.idea.published? }
        # validates :signature_end_date, date: { after: :signature_start_date }, if: lambda { |form|
        #   form.signature_start_date.present? && form.signature_end_date.present?
        # }
        # validates :signature_end_date, date: { after: Date.current }, if: lambda { |form|
        #   form.signature_start_date.blank? && form.signature_end_date.present?
        # }

        validate :notify_missing_attachment_if_errored
        validate :area_is_not_removed

        def map_model(model)
          self.type_id = model.type.id
          self.decidim_scope_id = model.scope&.id
          # self.offline_votes = offline_votes.empty? ? zero_offine_votes_with_scopes_names(model) : offline_votes_with_scopes_names(model)
        end

        # def signature_type_updatable?
        #   @signature_type_updatable ||= begin
        #     state ||= context.idea.state
        #     (state == "validating" && context.current_user.admin?) || state == "created"
        #   end
        # end

        def state_updatable?
          false
        end

        def area_updatable?
          @area_updatable ||= current_user.admin? || context.idea.created?
        end

        def scoped_type_id
          return unless type && decidim_scope_id

          type.scopes.find_by(decidim_scopes_id: decidim_scope_id.presence).id
        end

        def area
          @area ||= current_organization.areas.find_by(id: area_id)
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

        private

        # Private: set the in-person signatures to zero for every scope
        # def zero_offine_votes_with_scopes_names(model)
        #   model.votable_idea_type_scopes.each_with_object({}) do |idea_scope_type, all_votes|
        #     all_votes[idea_scope_type.decidim_scopes_id || "global"] = [0, idea_scope_type.scope_name]
        #   end
        # end

        # Private: set the in-person signatures for every scope
        # def offline_votes_with_scopes_names(model)
        #   model.offline_votes.delete("total")
        #   model.offline_votes.each_with_object({}) do |(decidim_scope_id, votes), all_votes|
        #     scope_name = model.votable_idea_type_scopes.find do |idea_scope_type|
        #       (idea_scope_type.global_scope? && decidim_scope_id == "global") ||
        #         idea_scope_type.decidim_scopes_id == decidim_scope_id.to_i
        #     end.scope_name

        #     all_votes[decidim_scope_id || "global"] = [votes, scope_name]
        #   end
        # end

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

        def area_is_not_removed
          return if context.idea.decidim_area_id.blank? || context.idea.created?

          errors.add(:area_id, :blank) if area_id.blank?
        end
      end
    end
  end
end
