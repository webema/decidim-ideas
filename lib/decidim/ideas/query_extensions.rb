# frozen_string_literal: true

module Decidim
  module Ideas
    # This module's job is to extend the API with custom fields related to
    # decidim-ideas.
    module QueryExtensions
      # Public: Extends a type with `decidim-ideas`'s fields.
      #
      # type - A GraphQL::BaseType to extend.
      #
      # Returns nothing.
      def self.included(type)
        type.field :ideas_types, [IdeaApiType], null: false do
          description "Lists all idea types"
        end

        type.field :ideas_type, IdeaApiType, null: true, description: "Finds a idea type" do
          argument :id, GraphQL::Types::ID, "The ID of the idea type", required: true
        end

        type.field :ideas,
                   [Decidim::Ideas::IdeaType],
                   null: true,
                   description: "Lists all ideas" do
          argument :filter, Decidim::ParticipatoryProcesses::ParticipatoryProcessInputFilter, "This argument lets you filter the results", required: false
          argument :order, Decidim::ParticipatoryProcesses::ParticipatoryProcessInputSort, "This argument lets you order the results", required: false
        end

        type.field :idea,
                   Decidim::Ideas::IdeaType,
                   null: true,
                   description: "Finds a idea" do
          argument :id, GraphQL::Types::ID, "The ID of the participatory space", required: false
        end
      end

      def ideas_types
        Decidim::IdeasType.where(
          organization: context[:current_organization]
        )
      end

      def ideas_type(id:)
        Decidim::IdeasType.find_by(
          organization: context[:current_organization],
          id: id
        )
      end

      def ideas(filter: {}, order: {})
        manifest = Decidim.participatory_space_manifests.select { |m| m.name == :ideas }.first
        Decidim::Core::ParticipatorySpaceListBase.new(manifest: manifest).call(object, { filter: filter, order: order }, context)
      end

      def idea(id: nil)
        manifest = Decidim.participatory_space_manifests.select { |m| m.name == :ideas }.first

        Decidim::Core::ParticipatorySpaceFinderBase.new(manifest: manifest).call(object, { id: id }, context)
      end
    end
  end
end
