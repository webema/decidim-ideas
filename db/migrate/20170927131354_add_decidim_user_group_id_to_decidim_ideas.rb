# frozen_string_literal: true

class AddDecidimUserGroupIdToDecidimIdeas < ActiveRecord::Migration[5.1]
  def change
    add_column :decidim_ideas,
               :decidim_user_group_id, :integer, index: true
  end
end
