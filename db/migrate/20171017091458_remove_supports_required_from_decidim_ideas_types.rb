# frozen_string_literal: true

class RemoveSupportsRequiredFromDecidimIdeasTypes < ActiveRecord::Migration[5.1]
  def change
    remove_column :decidim_ideas_types, :supports_required, :integer, null: false
  end
end
