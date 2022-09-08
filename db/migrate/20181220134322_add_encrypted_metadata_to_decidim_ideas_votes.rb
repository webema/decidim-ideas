# frozen_string_literal: true

class AddEncryptedMetadataToDecidimIdeasVotes < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_ideas_votes, :encrypted_metadata, :text
  end
end
