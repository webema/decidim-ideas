# frozen_string_literal: true
# TODO delete?

module Decidim
  module Ideas
    # Class uses to retrieve ideas that have been a long time in validating
    # state
    class SupportPeriodFinishedIdeas < Decidim::Query
      # Retrieves the ideas ready to be evaluated to decide if they've been
      # accepted or not.
      def query
        Decidim::Idea
          .includes(:scoped_type)
          .where(state: "published")
      end
    end
  end
end
