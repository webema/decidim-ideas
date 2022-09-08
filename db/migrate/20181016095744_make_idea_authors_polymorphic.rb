# frozen_string_literal: true

class MakeIdeaAuthorsPolymorphic < ActiveRecord::Migration[5.2]
  class Idea < ApplicationRecord
    self.table_name = :decidim_ideas
  end

  def change
    remove_index :decidim_ideas, :decidim_author_id

    add_column :decidim_ideas, :decidim_author_type, :string

    reversible do |direction|
      direction.up do
        execute <<~SQL.squish
          UPDATE decidim_ideas
          SET decidim_author_type = 'Decidim::UserBaseEntity'
        SQL
      end
    end

    add_index :decidim_ideas,
              [:decidim_author_id, :decidim_author_type],
              name: "index_decidim_ideas_on_decidim_author"

    change_column_null :decidim_ideas, :decidim_author_id, false
    change_column_null :decidim_ideas, :decidim_author_type, false

    Idea.reset_column_information
  end
end
