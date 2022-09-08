# frozen_string_literal: true

class AddBannerImageToIdeaType < ActiveRecord::Migration[5.1]
  def change
    add_column :decidim_ideas_types, :banner_image, :string
  end
end
