# frozen_string_literal: true

class UpdateIdeaScopedType < ActiveRecord::Migration[5.1]
  class IdeasTypeScope < ApplicationRecord
    self.table_name = :decidim_ideas_type_scopes
  end

  class Scope < ApplicationRecord
    self.table_name = :decidim_scopes

    # Scope to return only the top level scopes.
    #
    # Returns an ActiveRecord::Relation.
    def self.top_level
      where parent_id: nil
    end
  end

  class Organization < ApplicationRecord
    self.table_name = :decidim_organizations

    has_many :scopes, foreign_key: "decidim_organization_id", class_name: "Scope"

    # Returns top level scopes for this organization.
    #
    # Returns an ActiveRecord::Relation.
    def top_scopes
      @top_scopes ||= scopes.top_level
    end
  end

  class Idea < ApplicationRecord
    self.table_name = :decidim_ideas

    belongs_to :scoped_type,
               class_name: "IdeasTypeScope"

    belongs_to :organization,
               foreign_key: "decidim_organization_id",
               class_name: "Organization"
  end

  def up
    Idea.find_each do |idea|
      idea.scoped_type = IdeasTypeScope.find_by(
        decidim_ideas_types_id: idea.type_id,
        decidim_scopes_id: idea.decidim_scope_id || idea.organization.top_scopes.first
      )

      idea.save!
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration, "Can't undo initialization of mandatory attribute"
  end
end
