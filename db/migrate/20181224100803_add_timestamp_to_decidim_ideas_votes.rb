# frozen_string_literal: true

class AddTimestampToDecidimIdeasVotes < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_ideas_votes, :timestamp, :string
  end
end
