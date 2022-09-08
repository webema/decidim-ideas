# frozen_string_literal: true

module Decidim
  module Ideas
    # Class uses to retrieve ideas that have been a long time in
    # validating state
    class OutdatedValidatingIdeas < Decidim::Query
      # Syntactic sugar to initialize the class and return the queried objects.
      #
      # period_length - Maximum time in validating state
      def self.for(period_length)
        new(period_length).query
      end

      # Initializes the class.
      #
      # period_length - Maximum time in validating state
      def initialize(period_length)
        @period_length = Time.current - period_length
      end

      # Retrieves the available idea types for the given organization.
      def query
        Decidim::Idea
          .where(state: "validating")
          .where("updated_at < ?", @period_length)
      end
    end
  end
end
