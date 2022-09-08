# frozen_string_literal: true

module Decidim
  module IdeasVotes
    class VoteCell < Decidim::ViewModel
      delegate :timestamp, :hash_id, to: :model

      def show
        render
      end

      def idea_id
        model.idea.reference
      end

      def idea_title
        translated_attribute(model.idea.title)
      end

      def name_and_surname
        metadata[:name_and_surname]
      end

      def document_number
        metadata[:document_number]
      end

      def date_of_birth
        metadata[:date_of_birth]
      end

      def postal_code
        metadata[:postal_code]
      end

      def time_and_date
        model.created_at
      end

      def scope
        return I18n.t("decidim.scopes.global") if model.decidim_scope_id.nil?
        return I18n.t("decidim.ideas.unavailable_scope") if model.scope.blank?

        translated_attribute(model.scope.name)
      end

      protected

      def encryptor
        @encryptor ||= Decidim::Ideas::DataEncryptor.new(secret: "personal user metadata")
      end

      def metadata
        @metadata ||= model.encrypted_metadata ? encryptor.decrypt(model.encrypted_metadata) : {}
      end
    end
  end
end
