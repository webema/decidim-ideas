# frozen_string_literal: true

require "digest/sha1"

module Decidim
  # Ideas can be voted by users and supported by organizations.
  class IdeasVote < ApplicationRecord
    include Decidim::TranslatableAttributes

    belongs_to :author,
               foreign_key: "decidim_author_id",
               class_name: "Decidim::User"

    belongs_to :idea,
               foreign_key: "decidim_idea_id",
               class_name: "Decidim::Idea",
               inverse_of: :votes

    belongs_to :scope,
               foreign_key: "decidim_scope_id",
               class_name: "Decidim::Scope",
               optional: true

    validates :idea, uniqueness: { scope: [:author, :scope] }
    validates :idea, uniqueness: { scope: [:hash_id, :scope] }

    after_commit :update_counter_cache, on: [:create, :destroy]

    scope :for_scope, ->(scope) { where(scope: scope) }

    # Public: Generates a hashed representation of the idea support.
    #
    # Used when exporting the votes as CSV.
    def sha1
      title = translated_attribute(idea.title)
      description = translated_attribute(idea.description)

      Digest::SHA1.hexdigest "#{authorization_unique_id}#{title}#{description}"
    end

    def decrypted_metadata
      @decrypted_metadata ||= encrypted_metadata ? encryptor.decrypt(encrypted_metadata) : {}
    end

    private

    def encryptor
      @encryptor ||= Decidim::Ideas::DataEncryptor.new(secret: "personal user metadata")
    end

    def authorization_unique_id
      first_authorization = Decidim::Ideas::UserAuthorizations
                            .for(author)
                            .first

      first_authorization&.unique_id || author.email
    end

    def update_counter_cache
      idea.update_online_votes_counters
    end
  end
end
