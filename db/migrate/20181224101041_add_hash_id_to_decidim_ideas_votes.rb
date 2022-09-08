# frozen_string_literal: true

class AddHashIdToDecidimIdeasVotes < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_ideas_votes, :hash_id, :string
  end
end
