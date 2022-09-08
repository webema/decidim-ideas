# frozen_string_literal: true

class AddScopesToIdeasVotes < ActiveRecord::Migration[5.2]
  class IdeaVote < ApplicationRecord
    self.table_name = :decidim_ideas_votes
    belongs_to :idea, foreign_key: "decidim_idea_id", class_name: "Idea"
  end

  class Idea < ApplicationRecord
    self.table_name = :decidim_ideas
    belongs_to :scoped_type, class_name: "IdeasTypeScope"
  end

  class IdeasTypeScope < ApplicationRecord
    self.table_name = :decidim_ideas_type_scopes
  end

  def change
    add_column :decidim_ideas_votes, :decidim_scope_id, :integer

    IdeaVote.reset_column_information

    IdeaVote.includes(idea: :scoped_type).find_each do |vote|
      vote.decidim_scope_id = vote.idea.scoped_type.decidim_scopes_id
      vote.save!
    end
  end
end
