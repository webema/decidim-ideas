# frozen_string_literal: true

class AddIdeaSupportsCountToIdea < ActiveRecord::Migration[5.1]
  class Idea < ApplicationRecord
    self.table_name = :decidim_ideas
  end

  def change
    add_column :decidim_ideas, :idea_supports_count, :integer, null: false, default: 0

    reversible do |change|
      change.up do
        Idea.find_each do |idea|
          idea.idea_supports_count = idea.votes.supports.count
          idea.save
        end
      end
    end
  end
end
