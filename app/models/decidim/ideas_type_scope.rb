# frozen_string_literal: true

module Decidim
  class IdeasTypeScope < ApplicationRecord
    belongs_to :type,
               foreign_key: "decidim_ideas_types_id",
               class_name: "Decidim::IdeasType",
               inverse_of: :scopes

    belongs_to :scope,
               foreign_key: "decidim_scopes_id",
               class_name: "Decidim::Scope",
               optional: true

    has_many :ideas,
             foreign_key: "scoped_type_id",
             class_name: "Decidim::Idea",
             dependent: :restrict_with_error,
             inverse_of: :scoped_type

    validates :scope, uniqueness: { scope: :type }

    def global_scope?
      decidim_scopes_id.nil?
    end

    def scope_name
      return { I18n.locale.to_s => I18n.t("decidim.scopes.global") } if global_scope?

      scope&.name.presence || { I18n.locale.to_s => I18n.t("decidim.ideas.unavailable_scope") }
    end
  end
end
