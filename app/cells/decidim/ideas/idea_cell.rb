# frozen_string_literal: true

module Decidim
  module Ideas
    # This cell renders the process card for an instance of an Idea
    # the default size is the Medium Card (:m)
    class IdeaCell < Decidim::ViewModel
      def show
        cell card_size, model, options
      end

      private

      def card_size
        "decidim/ideas/idea_m"
      end
    end
  end
end
