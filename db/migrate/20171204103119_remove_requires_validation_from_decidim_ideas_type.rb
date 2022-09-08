# frozen_string_literal: true

class RemoveRequiresValidationFromDecidimIdeasType < ActiveRecord::Migration[5.1]
  def change
    remove_column :decidim_ideas_types,
                  :requires_validation, :boolean, null: false, default: true
  end
end
