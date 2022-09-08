# frozen-string_literal: true

module Decidim
  module Ideas
    class EndorseIdeaEvent < Decidim::Events::SimpleEvent
      include Decidim::Events::AuthorEvent

      def i18n_scope
        "decidim.ideas.events.endorse_idea_event"
      end
    end
  end
end
