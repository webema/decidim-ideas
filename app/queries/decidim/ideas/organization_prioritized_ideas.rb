# frozen_string_literal: true

module Decidim
  module Ideas
    # This query retrieves the organization prioritized ideas that will appear in the homepage
    class OrganizationPrioritizedIdeas < Decidim::Query
      attr_reader :organization, :order

      def initialize(organization, order)
        @organization = organization
        @order = order
      end

      def query
        if order == "most_recent"
          base_query.order_by_most_recently_published
        else
          base_query
        end
      end

      private

      def base_query
        Decidim::Idea.where(organization: organization).published.open
      end
    end
  end
end
