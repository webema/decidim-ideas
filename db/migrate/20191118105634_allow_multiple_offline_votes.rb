# frozen_string_literal: true

class AllowMultipleOfflineVotes < ActiveRecord::Migration[5.2]
  class IdeasTypeScope < ApplicationRecord
    self.table_name = :decidim_ideas_type_scopes
  end

  class Idea < ApplicationRecord
    self.table_name = :decidim_ideas
    belongs_to :scoped_type, class_name: "IdeasTypeScope"
  end

  def change
    rename_column :decidim_ideas, :offline_votes, :old_offline_votes
    add_column :decidim_ideas, :offline_votes, :jsonb, default: {}

    Idea.reset_column_information

    Idea.includes(:scoped_type).find_each do |idea|
      scope_key = idea.scoped_type.decidim_scopes_id || "global"

      offline_votes = {
        scope_key => idea.old_offline_votes.to_i,
        "total" => idea.old_offline_votes.to_i
      }

      # rubocop:disable Rails/SkipsModelValidations
      idea.update_column(:offline_votes, offline_votes)
      # rubocop:enable Rails/SkipsModelValidations
    end

    remove_column :decidim_ideas, :old_offline_votes
  end
end
