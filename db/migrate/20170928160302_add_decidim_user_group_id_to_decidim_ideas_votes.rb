# frozen_string_literal: true

class AddDecidimUserGroupIdToDecidimIdeasVotes < ActiveRecord::Migration[5.1]
  def change
    add_column :decidim_ideas_votes,
               :decidim_user_group_id, :integer, index: true
  end
end
