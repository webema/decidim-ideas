# frozen_string_literal: true

module Decidim
  module Ideas
    # This type represents a idea committee member.
    class IdeaCommitteeMemberType < Decidim::Api::Types::BaseObject
      graphql_name "IdeaCommitteeMemberType"
      description "A idea committee member"

      field :id, GraphQL::Types::ID, "Internal ID for this member of the committee", null: false
      field :user, Decidim::Core::UserType, "The decidim user for this idea committee member", null: true

      field :state, GraphQL::Types::String, "Type of the committee member", null: true
      field :created_at, Decidim::Core::DateTimeType, "The date this idea committee member was created", null: true
      field :updated_at, Decidim::Core::DateTimeType, "The date this idea committee member was updated", null: true
    end
  end
end
