class ActiveFlagForIdeaTypes < ActiveRecord::Migration[6.1]
  def change
    add_column :decidim_ideas_types, :active, :boolean, default: true
  end
end
