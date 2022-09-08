# frozen_string_literal: true

module Decidim
  #
  # Decorator for ideas
  #
  class IdeaPresenter < SimpleDelegator
    def author
      @author ||= if user_group
                    Decidim::UserGroupPresenter.new(user_group)
                  else
                    Decidim::UserPresenter.new(super)
                  end
    end
  end
end
