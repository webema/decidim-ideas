# frozen_string_literal: true

class AddScopedTypeToIdea < ActiveRecord::Migration[5.1]
  def change
    add_column :decidim_ideas,
               :scoped_type_id, :integer, index: true
  end
end
