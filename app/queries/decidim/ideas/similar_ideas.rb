# frozen_string_literal: true

module Decidim
  module Ideas
    # Class uses to retrieve similar ideas types.
    class SimilarIdeas < Decidim::Query
      include Decidim::TranslationsHelper
      include CurrentLocale

      # Syntactic sugar to initialize the class and return the queried objects.
      #
      # organization - Decidim::Organization
      # form - Decidim::Ideas::PreviousForm
      def self.for(organization, form)
        new(organization, form).query
      end

      # Initializes the class.
      #
      # organization - Decidim::Organization
      # form - Decidim::Ideas::PreviousForm
      def initialize(organization, form)
        @organization = organization
        @form = form
      end

      # Retrieves similar ideas
      def query
        Idea
          .published
          .where(organization: @organization)
          .where(
            Arel.sql("GREATEST(#{title_similarity}, #{description_similarity}) >= ?").to_s,
            form.title,
            form.description,
            Decidim::Ideas.similarity_threshold
          )
          .limit(Decidim::Ideas.similarity_limit)
      end

      private

      attr_reader :form

      def title_similarity
        "similarity(title->>'#{current_locale}', ?)"
      end

      def description_similarity
        "similarity(description->>'#{current_locale}', ?)"
      end
    end
  end
end
