# frozen_string_literal: true

class AllowMultipleIdeaVotesCounterCaches < ActiveRecord::Migration[5.2]
  class IdeaVote < ApplicationRecord
    self.table_name = :decidim_ideas_votes
  end

  class Idea < ApplicationRecord
    self.table_name = :decidim_ideas
    has_many :votes, foreign_key: "decidim_idea_id", class_name: "IdeaVote"
  end

  def change
    add_column :decidim_ideas, :online_votes, :jsonb, default: {}

    Idea.reset_column_information

    Idea.find_each do |idea|
      online_votes = idea.votes.group(:decidim_scope_id).count.each_with_object({}) do |(scope_id, count), counters|
        counters[scope_id || "global"] = count
        counters["total"] = count
      end

      # rubocop:disable Rails/SkipsModelValidations
      idea.update_column("online_votes", online_votes)
      # rubocop:enable Rails/SkipsModelValidations
    end

    remove_column :decidim_ideas, :idea_supports_count
    remove_column :decidim_ideas, :idea_votes_count
  end
end
