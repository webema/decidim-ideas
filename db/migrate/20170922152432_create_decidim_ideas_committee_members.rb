# frozen_string_literal: true

# Migration that creates the decidim_ideas_committee_members table
class CreateDecidimIdeasCommitteeMembers < ActiveRecord::Migration[5.1]
  def change
    create_table :decidim_ideas_committee_members do |t|
      t.references :decidim_ideas, index: {
        name: "index_decidim_committee_members_idea"
      }
      t.references :decidim_users, index: {
        name: "index_decidim_committee_members_user"
      }
      t.integer :state, index: true, null: false, default: 0

      t.timestamps
    end
  end
end
