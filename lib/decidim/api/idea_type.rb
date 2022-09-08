# frozen_string_literal: true

module Decidim
  module Ideas
    # This type represents a Idea.
    class IdeaType < Decidim::Api::Types::BaseObject
      implements Decidim::Core::ParticipatorySpaceInterface
      implements Decidim::Core::ScopableInterface
      implements Decidim::Core::AttachableInterface
      implements Decidim::Ideas::IdeaTypeInterface
      implements Decidim::Core::TimestampsInterface

      description "A idea"

      field :description, Decidim::Core::TranslatedFieldType, "The description of this idea.", null: true
      field :slug, GraphQL::Types::String, null: false
      field :hashtag, GraphQL::Types::String, "The hashtag for this idea", null: true
      field :published_at, Decidim::Core::DateTimeType, "The time this idea was published", null: false
      field :reference, GraphQL::Types::String, "Reference prefix for this idea", null: false
      field :state, GraphQL::Types::String, "Current status of the idea", null: true
      field :signature_type, GraphQL::Types::String, "Signature type of the idea", null: true
      field :signature_start_date, Decidim::Core::DateType, "The signature start date", null: false
      field :signature_end_date, Decidim::Core::DateType, "The signature end date", null: false
      field :offline_votes, GraphQL::Types::Int, "The number of offline votes in this idea", method: :offline_votes_count, null: true
      field :online_votes, GraphQL::Types::Int, "The number of online votes in this idea", method: :online_votes_count, null: true
      field :idea_votes_count, GraphQL::Types::Int,
            description: "The number of votes in this idea",
            deprecation_reason: "ideaVotesCount has been collapsed in onlineVotes parameter",
            null: true
      field :idea_supports_count, GraphQL::Types::Int,
            description: "The number of supports in this idea",
            method: :online_votes_count,
            deprecation_reason: "ideaSupportsCount has been collapsed in onlineVotes parameter",
            null: true

      field :author, Decidim::Core::AuthorInterface, "The idea author", null: false

      def idea_votes_count
        object.online_votes_count
      end

      def author
        object.user_group || object.author
      end

      field :committee_members, [Decidim::Ideas::IdeaCommitteeMemberType, { null: true }], null: true
    end
  end
end
