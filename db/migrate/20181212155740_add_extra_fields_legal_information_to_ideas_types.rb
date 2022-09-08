# frozen_string_literal: true

class AddExtraFieldsLegalInformationToIdeasTypes < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_ideas_types, :extra_fields_legal_information, :jsonb
  end
end
