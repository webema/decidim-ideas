# frozen_string_literal: true

class AddOnlineSignatureEnabledToIdeaType < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_ideas_types, :online_signature_enabled, :boolean, null: false, default: true
  end
end
