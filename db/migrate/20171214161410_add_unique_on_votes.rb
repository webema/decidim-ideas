# This migration comes from decidim_ideas (originally 20171214161410)
# frozen_string_literal: true

class AddUniqueOnVotes < ActiveRecord::Migration[5.1]
  class IdeasVote < ApplicationRecord
    self.table_name = :decidim_ideas_votes
  end

  def get_duplicates(*columns)
    IdeasVote.select("#{columns.join(",")}, COUNT(*)").group(columns).having("COUNT(*) > 1")
  end

  def row_count(issue)
    IdeasVote.where(
      decidim_idea_id: issue.decidim_idea_id,
      decidim_author_id: issue.decidim_author_id,
      decidim_user_group_id: issue.decidim_user_group_id
    ).count
  end

  def find_next(issue)
    IdeasVote.find_by(
      decidim_idea_id: issue.decidim_idea_id,
      decidim_author_id: issue.decidim_author_id,
      decidim_user_group_id: issue.decidim_user_group_id
    )
  end

  def up
    columns = [:decidim_idea_id, :decidim_author_id, :decidim_user_group_id]

    get_duplicates(columns).each do |issue|
      find_next(issue)&.destroy while row_count(issue) > 1
    end

    add_index :decidim_ideas_votes,
              columns,
              unique: true,
              name: "decidim_ideas_voutes_author_uniqueness_index"
  end
end
