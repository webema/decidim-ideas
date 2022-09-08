# frozen_string_literal: true

class RemoveUnusedAttributesFromIdea < ActiveRecord::Migration[5.1]
  def change
    remove_column :decidim_ideas, :banner_image, :string
    remove_column :decidim_ideas, :decidim_scope_id, :integer, index: true
    remove_column :decidim_ideas, :type_id, :integer, index: true
  end
end
