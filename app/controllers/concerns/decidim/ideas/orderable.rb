# frozen_string_literal: true

require "active_support/concern"

module Decidim
  module Ideas
    # Common logic to ordering resources
    module Orderable
      extend ActiveSupport::Concern

      included do
        include Decidim::Orderable

        # Available orders based on enabled settings
        def available_orders
          @available_orders ||= begin
            available_orders = %w(random recent most_voted most_commented recently_published)
            available_orders
          end
        end

        def default_order
          "random"
        end

        def reorder(ideas)
          case order
          when "most_voted"
            ideas.order_by_supports
          when "most_commented"
            ideas.order_by_most_commented
          when "recent"
            ideas.order_by_most_recent
          when "recently_published"
            ideas.order_by_most_recently_published
          else
            ideas.order_randomly(random_seed)
          end
        end

        def order
          @order ||= detect_order(params[:order]) || current_ideas_settings.ideas_order || default_order
        end

        def current_ideas_settings
          @current_ideas_settings ||= Decidim::IdeasSettings.find_or_create_by!(organization: current_organization)
        end
      end
    end
  end
end
