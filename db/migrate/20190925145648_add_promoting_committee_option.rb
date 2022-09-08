# frozen_string_literal: true

class AddPromotingCommitteeOption < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_ideas_types, :promoting_committee_enabled, :boolean, null: false, default: true
  end
end
