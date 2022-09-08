# frozen_string_literal: true

class CreateDecidimIdeasTypes < ActiveRecord::Migration[5.1]
  def change
    create_table :decidim_ideas_types do |t|
      t.jsonb :title, null: false
      t.jsonb :description, null: false
      t.integer :supports_required, null: false

      t.integer :decidim_organization_id,
                foreign_key: true,
                index: {
                  name: "index_decidim_idea_types_on_decidim_organization_id"
                }

      t.timestamps
    end
  end
end
