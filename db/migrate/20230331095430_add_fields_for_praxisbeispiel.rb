class AddFieldsForPraxisbeispiel < ActiveRecord::Migration[6.1]
  def change
    add_column :decidim_ideas, :problem, :jsonb
    add_column :decidim_ideas, :current_state, :jsonb
    add_column :decidim_ideas, :steps, :jsonb
    add_column :decidim_ideas, :boards, :jsonb
    add_column :decidim_ideas, :obstacles, :jsonb
    add_column :decidim_ideas, :time, :jsonb
    add_column :decidim_ideas, :hours, :jsonb
    add_column :decidim_ideas, :cooperations, :jsonb
    add_column :decidim_ideas, :staff, :jsonb
    add_column :decidim_ideas, :working_hours, :jsonb
    add_column :decidim_ideas, :costs, :jsonb
    add_column :decidim_ideas, :info, :jsonb
  end
end
