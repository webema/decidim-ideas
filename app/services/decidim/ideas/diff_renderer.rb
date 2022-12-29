# frozen_string_literal: true

module Decidim
  module Ideas
    class DiffRenderer < BaseDiffRenderer
      private

      # Lists which attributes will be diffable and how they should be rendered.
      def attribute_types
        {
          title: :i18n,
          description: :i18n_html,
          source: :i18n,
          state: :string
        }
      end
    end
  end
end
