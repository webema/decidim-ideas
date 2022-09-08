# frozen_string_literal: true

class RemoveScopeFromDecidimIdeasVotes < ActiveRecord::Migration[5.1]
  def change
    remove_column :decidim_ideas_votes, :scope, :integer
  end
end
