# frozen_string_literal: true

class AddCommentsEnabledToIdeaTypes < ActiveRecord::Migration[6.1]
  def change
    add_column :decidim_ideas_types, :comments_enabled, :boolean, null: false, default: true
  end
end
