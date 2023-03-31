class AddFieldsForPraxisbeispiel < ActiveRecord::Migration[6.1]
  def change
    add_column :decidim_ideas, :problem, :text
    add_column :decidim_ideas, :current_state, :text
    add_column :decidim_ideas, :steps, :text
    add_column :decidim_ideas, :boards, :text
    add_column :decidim_ideas, :obstacles, :text
    add_column :decidim_ideas, :time, :text
    add_column :decidim_ideas, :hours, :text
    add_column :decidim_ideas, :cooperations, :text
    add_column :decidim_ideas, :staff, :text
    add_column :decidim_ideas, :working_hours, :text
    add_column :decidim_ideas, :costs, :text
    add_column :decidim_ideas, :info, :text
  end
end
