# frozen_string_literal: true

module Decidim
  module Ideas
    # Helper functions for ideas views
    module IdeasHelper
      def ideas_filter_form_for(filter)
        content_tag :div, class: "filters" do
          form_for filter,
                   namespace: filter_form_namespace,
                   builder: Decidim::Ideas::IdeasFilterFormBuilder,
                   url: url_for,
                   as: :filter,
                   method: :get,
                   remote: true,
                   html: { id: nil } do |form|
            yield form
          end
        end
      end

      private

      # Creates a unique namespace for a filter form to prevent dupliacte IDs in
      # the DOM when multiple filter forms are rendered with the same fields (e.g.
      # for desktop and mobile).
      def filter_form_namespace
        "filters_#{SecureRandom.uuid}"
      end
    end
  end
end
