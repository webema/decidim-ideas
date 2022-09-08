# frozen_string_literal: true

require "active_support/concern"

module Decidim
  module Ideas
    module Admin
      # This concern is meant to be included in all controllers that are scoped
      # into an idea's admin panel. It will override the layout so it shows
      # the sidebar, preload the assembly, etc.
      module IdeaAdmin
        extend ActiveSupport::Concern
        include IdeaSlug

        included do
          include NeedsIdea

          include Decidim::Admin::ParticipatorySpaceAdminContext
          participatory_space_admin_layout

          alias_method :current_participatory_space, :current_idea
          alias_method :current_participatory_space_manifest, :ideas_manifest
        end

        private

        def ideas_manifest
          @ideas_manifest ||= Decidim.find_participatory_space_manifest(:ideas)
        end
      end
    end
  end
end
