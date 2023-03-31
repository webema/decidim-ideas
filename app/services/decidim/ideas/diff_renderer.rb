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
          problem: :i18n,
          current_state: :i18n,
          info: :i18n,
          steps: :i18n,
          boards: :i18n,
          obstacles: :i18n,
          time: :i18n,
          hours: :i18n,
          cooperations: :i18n,
          staff: :i18n,
          working_hours: :i18n,
          costs: :i18n,
          source: :i18n,
          state: :string
        }
      end
    end
  end
end
