# frozen_string_literal: true

module Decidim
  module Ideas
    module Admin
      # A form object used to collect the all the idea type attributes.
      class IdeaTypeForm < Decidim::Form
        include TranslatableAttributes

        mimic :ideas_type

        translatable_attribute :title, String
        translatable_attribute :description, String
        
        attribute :banner_image
        attribute :attachments_enabled, Boolean
        attribute :comments_enabled, Boolean
        attribute :only_global_scope_enabled, Boolean


        validates :title, :description, translatable_presence: true
        validates :attachments_enabled, inclusion: { in: [true, false] }
        validates :banner_image, presence: true, if: ->(form) { !form.persisted? && form.context.idea_type.nil? }
        validates :banner_image, passthru: { to: Decidim::IdeasType }

        alias organization current_organization
      end
    end
  end
end
