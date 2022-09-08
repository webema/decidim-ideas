# frozen_string_literal: true

class IndexForeignKeysInDecidimIdeas < ActiveRecord::Migration[5.2]
  def change
    add_index :decidim_ideas, :decidim_user_group_id
    add_index :decidim_ideas, :scoped_type_id
  end
end
