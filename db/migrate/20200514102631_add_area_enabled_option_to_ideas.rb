# frozen_string_literal: true

class AddAreaEnabledOptionToIdeas < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_ideas_types, :area_enabled, :boolean, null: false, default: false
  end
end
