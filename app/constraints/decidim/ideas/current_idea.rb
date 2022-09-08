# frozen_string_literal: true

module Decidim
  module Ideas
    # This class infers the current idea we're scoped to by
    # looking at the request parameters and the organization in the request
    # environment, and injects it into the environment.
    class CurrentIdea
      include IdeaSlug

      # Public: Matches the request against an initative and injects it
      #         into the environment.
      #
      # request - The request that holds the idea relevant
      #           information.
      #
      # Returns a true if the request matched, false otherwise
      def matches?(request)
        env = request.env

        @organization = env["decidim.current_organization"]
        return false unless @organization

        current_idea(env, request.params) ? true : false
      end

      private

      def current_idea(env, params)
        env["decidim.current_participatory_space"] ||= Idea.find_by(id: id_from_slug(params[:idea_slug]))
      end
    end
  end
end
