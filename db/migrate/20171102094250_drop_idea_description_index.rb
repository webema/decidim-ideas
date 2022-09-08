# frozen_string_literal: true

class DropIdeaDescriptionIndex < ActiveRecord::Migration[5.1]
  def change
    remove_index :decidim_ideas, :description
  end
end
