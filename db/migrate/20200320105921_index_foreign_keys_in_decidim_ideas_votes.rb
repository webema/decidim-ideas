# frozen_string_literal: true

class IndexForeignKeysInDecidimIdeasVotes < ActiveRecord::Migration[5.2]
  def change
    add_index :decidim_ideas_votes, :decidim_user_group_id
    add_index :decidim_ideas_votes, :hash_id
  end
end
