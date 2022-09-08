# frozen_string_literal: true

module Decidim
  module Ideas
    class IdeaSerializer < Decidim::Exporters::Serializer
      # Serializes an inititative
      def serialize
        {
          id: resource.id,
          title: resource.title,
          description: resource.description,
          state: resource.state,
          created_at: resource.created_at,
          published_at: resource.published_at,
          scope: {
            name: resource.scope&.name
          },
          type: {
            title: resource.type&.title
          },
          authors: {
            id: resource.author_users.map(&:id),
            name: resource.author_users.map(&:name)
          },
          area: {
            name: resource.area&.name
          }
        }
      end
    end
  end
end
