class AddSourceFieldToIdeas < ActiveRecord::Migration[6.1]
  def change
    add_column :decidim_ideas, :source, :jsonb
  end
end
