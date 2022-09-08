# frozen_string_literal: true

require "active_support/concern"

module Decidim
  module Ideas
    # Common logic for elements that need to be able to select idea types.
    module TypeSelectorOptions
      extend ActiveSupport::Concern

      include Decidim::TranslationsHelper

      included do
        helper_method :available_idea_types, :idea_type_options,
                      :idea_types_each

        private

        # Return all idea types with scopes defined.
        def available_idea_types
          Decidim::Ideas::IdeaTypes
            .for(current_organization)
            .joins(:scopes)
            .distinct
        end

        def idea_type_options
          available_idea_types.map do |type|
            [type.title[I18n.locale.to_s], type.id]
          end
        end

        def idea_types_each
          available_idea_types.each do |type|
            yield(type)
          end
        end
      end
    end
  end
end
