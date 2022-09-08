# frozen-string_literal: true

module Decidim
  module Ideas
    class ExtendIdeaEvent < Decidim::Events::SimpleEvent
      def participatory_space
        resource
      end
    end
  end
end
