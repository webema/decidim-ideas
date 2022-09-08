# frozen_string_literal: true

class AddSettingsToIdeasTypes < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_ideas_types, :child_scope_threshold_enabled, :boolean, null: false, default: false
    add_column :decidim_ideas_types, :only_global_scope_enabled, :boolean, null: false, default: false
  end
end
