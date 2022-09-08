# frozen_string_literal: true

class AddCollectExtraUserFieldsToIdeasTypes < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_ideas_types, :collect_user_extra_fields, :boolean, default: false
  end
end
