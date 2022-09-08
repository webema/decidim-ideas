# frozen_string_literal: true

class CreateDecidimIdeasDecidimIdeasTypeScopes < ActiveRecord::Migration[5.1]
  def change
    create_table :decidim_ideas_type_scopes do |t|
      t.references :decidim_ideas_types, index: { name: "idx_scoped_idea_type_type" }
      t.references :decidim_scopes, index: { name: "idx_scoped_idea_type_scope" }
      t.integer :supports_required, null: false

      t.timestamps
    end
  end
end
