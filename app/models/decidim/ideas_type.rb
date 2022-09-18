# frozen_string_literal: true

module Decidim
  # Idea type.
  class IdeasType < ApplicationRecord
    include Decidim::HasResourcePermission
    include Decidim::TranslatableResource
    include Decidim::HasUploadValidations
    include Decidim::Traceable

    translatable_fields :title, :description

    belongs_to :organization,
               foreign_key: "decidim_organization_id",
               class_name: "Decidim::Organization"

    has_many :scopes,
             foreign_key: "decidim_ideas_types_id",
             class_name: "Decidim::IdeasTypeScope",
             dependent: :destroy,
             inverse_of: :type

    has_many :ideas,
             through: :scopes,
             class_name: "Decidim::Idea"

    validates :title, :description, presence: true

    has_one_attached :banner_image
    validates_upload :banner_image, uploader: Decidim::BannerImageUploader

    def allow_resource_permissions?
      true
    end

    def mounted_admin_engine
      "decidim_admin_ideas"
    end

    def mounted_params
      { host: organization.host }
    end

    def self.log_presenter_class_for(_log)
      Decidim::Ideas::AdminLog::IdeasTypePresenter
    end
  end
end
