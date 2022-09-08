# frozen_string_literal: true

class RemoveUserGroupsFromIdeaVotes < ActiveRecord::Migration[5.2]
  def change
    remove_column :decidim_ideas_votes, :decidim_user_group_id
  end
end
