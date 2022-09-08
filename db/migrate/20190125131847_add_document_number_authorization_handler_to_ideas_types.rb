# frozen_string_literal: true

class AddDocumentNumberAuthorizationHandlerToIdeasTypes < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_ideas_types, :document_number_authorization_handler, :string
  end
end
