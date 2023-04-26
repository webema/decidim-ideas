class RemoveObsoleteIdeasFields < ActiveRecord::Migration[6.1]
  def change
    remove_column :decidim_ideas, :current_state
    remove_column :decidim_ideas, :boards
    remove_column :decidim_ideas, :time
    remove_column :decidim_ideas, :hours
    remove_column :decidim_ideas, :cooperations
    remove_column :decidim_ideas, :working_hours
    remove_column :decidim_ideas, :costs

    add_column :decidim_ideas, :miscellaneous, :jsonb
  end
end
