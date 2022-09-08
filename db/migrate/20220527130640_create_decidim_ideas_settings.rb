# frozen_string_literal: true

class CreateDecidimIdeasSettings < ActiveRecord::Migration[5.2]
  def change
    create_table :decidim_ideas_settings do |t|
      t.string :ideas_order, default: "random"
      t.references :decidim_organization, foreign_key: true, index: true
    end
  end
end
