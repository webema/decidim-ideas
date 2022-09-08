# frozen_string_literal: true

class AddUndoOnlineSignaturesEnabledToIdeasTypes < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_ideas_types, :undo_online_signatures_enabled, :boolean, null: false, default: true
  end
end
