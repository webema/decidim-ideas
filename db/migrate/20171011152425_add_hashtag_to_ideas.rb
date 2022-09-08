# frozen_string_literal: true

class AddHashtagToIdeas < ActiveRecord::Migration[5.1]
  def change
    add_column :decidim_ideas, :hashtag, :string, unique: true
  end
end
