# frozen_string_literal: true

class CreateIdeaDescriptionIndex < ActiveRecord::Migration[5.1]
  def up
    execute "CREATE INDEX decidim_ideas_description_search ON decidim_ideas(md5(description::text))"
  end

  def down
    execute "DROP INDEX decidim_ideas_description_search"
  end
end
