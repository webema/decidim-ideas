# frozen_string_literal: true

require "active_support/concern"

module Decidim
  module Ideas
    # Common methods for elements that need specific behaviour when there is only one idea type.
    module SingleIdeaType
      extend ActiveSupport::Concern

      included do
        helper_method :single_idea_type?, :single_active_idea_type?

        private

        def current_organization_ideas_type
          Decidim::IdeasType.where(organization: current_organization)
        end

        def single_idea_type?
          current_organization_ideas_type.count == 1
        end

        def single_active_idea_type?
          current_organization_ideas_type.active.count == 1
        end
      end
    end
  end
end
