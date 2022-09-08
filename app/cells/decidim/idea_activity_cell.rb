# frozen_string_literal: true

module Decidim
  # A cell to display when an idea has been published.
  class IdeaActivityCell < ActivityCell
    def title
      I18n.t "decidim.ideas.last_activity.new_idea"
    end
  end
end
