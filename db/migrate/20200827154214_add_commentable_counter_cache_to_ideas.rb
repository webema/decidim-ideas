# frozen_string_literal: true

class AddCommentableCounterCacheToIdeas < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_ideas, :comments_count, :integer, null: false, default: 0, index: true
    Decidim::Idea.reset_column_information
    Decidim::Idea.find_each(&:update_comments_count)
  end
end
