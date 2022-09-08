# frozen_string_literal: true

class AddOfflineVotesToIdea < ActiveRecord::Migration[5.1]
  def change
    add_column :decidim_ideas,
               :offline_votes, :integer
  end
end
