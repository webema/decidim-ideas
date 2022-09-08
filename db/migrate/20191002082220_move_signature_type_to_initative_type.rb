# frozen_string_literal: true

class MoveSignatureTypeToInitativeType < ActiveRecord::Migration[5.2]
  class IdeasType < ApplicationRecord
    self.table_name = :decidim_ideas_types
  end

  def change
    if !ActiveRecord::Base.connection.table_exists?("decidim_ideas_types")
      Rails.logger.info "Skipping migration since there's no IdeasType table"
      return
    elsif IdeasType.count.positive?
      raise "You need to edit this migration to continue"
    end

    # This flag says when mixed and face-to-face voting methods
    # are allowed. If set to false, only online voting will be
    # allowed
    # face_to_face_voting_allowed = true

    add_column :decidim_ideas_types, :signature_type, :integer, null: false, default: 0

    IdeasType.reset_column_information

    IdeasType.find_each do |type|
      type.signature_type = if type.online_signature_enabled && face_to_face_voting_allowed
                              :any
                            elsif type.online_signature_enabled && !face_to_face_voting_allowed
                              :online
                            else
                              :offline
                            end
      type.save!
    end

    remove_column :decidim_ideas_types, :online_signature_enabled
  end
end
