# frozen_string_literal: true

module Decidim
  module Ideas
    # Exposes Ideas versions so users can see how an Idea
    # has been updated through time.
    class VersionsController < Decidim::Ideas::ApplicationController
      include ParticipatorySpaceContext
      participatory_space_layout
      helper IdeaHelper

      include NeedsIdea
      include Decidim::ResourceVersionsConcern

      def versioned_resource
        current_idea
      end

      private

      def current_participatory_space_manifest
        @current_participatory_space_manifest ||= Decidim.find_participatory_space_manifest(:ideas)
      end
    end
  end
end
