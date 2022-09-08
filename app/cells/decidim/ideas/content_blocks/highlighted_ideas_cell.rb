# frozen_string_literal: true

module Decidim
  module Ideas
    module ContentBlocks
      class HighlightedIdeasCell < Decidim::ViewModel
        include Decidim::SanitizeHelper

        delegate :current_organization, to: :controller

        def show
          render if highlighted_ideas.any?
        end

        def max_results
          model.settings.max_results
        end

        def order
          model.settings.order
        end

        def highlighted_ideas
          @highlighted_ideas ||= OrganizationPrioritizedIdeas
                                       .new(current_organization, order)
                                       .query
                                       .limit(max_results)
        end

        def i18n_scope
          "decidim.ideas.pages.home.highlighted_ideas"
        end

        def decidim_ideas
          Decidim::Ideas::Engine.routes.url_helpers
        end
      end
    end
  end
end
