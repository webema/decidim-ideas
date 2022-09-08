# frozen_string_literal: true

class AddAreaToIdeas < ActiveRecord::Migration[5.2]
  def change
    add_reference :decidim_ideas, :decidim_area, index: true
  end
end
