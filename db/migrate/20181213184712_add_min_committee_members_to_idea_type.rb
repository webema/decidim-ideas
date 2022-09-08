# frozen_string_literal: true

class AddMinCommitteeMembersToIdeaType < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_ideas_types, :minimum_committee_members, :integer, null: true, default: nil
  end
end
