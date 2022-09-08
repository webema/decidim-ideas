# frozen_string_literal: true

module Decidim
  module Ideas
    # This controller provides a widget that allows embedding the idea
    class WidgetsController < Decidim::WidgetsController
      helper IdeasHelper
      helper PaginateHelper
      helper IdeaHelper
      helper Decidim::Comments::CommentsHelper
      helper Decidim::Admin::IconLinkHelper

      include NeedsIdea

      private

      def model
        @model ||= current_idea
      end

      def current_participatory_space
        model
      end

      def iframe_url
        @iframe_url ||= idea_widget_url(model)
      end
    end
  end
end
