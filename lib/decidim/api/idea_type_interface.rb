# frozen_string_literal: true

module Decidim
  module Ideas
    # This interface represents a commentable object.

    module IdeaTypeInterface
      include Decidim::Api::Types::BaseInterface
      description "An interface that can be used in Idea objects."

      field :idea_type, Decidim::Ideas::IdeaApiType, "The object's idea type", null: true

      def idea_type
        object.type
      end
    end
  end
end
