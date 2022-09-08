# frozen_string_literal: true

module Decidim
  module Ideas
    module Admin
      # A command with all the business logic that publishes an
      # existing idea.
      class PublishIdea < Decidim::Command
        # Public: Initializes the command.
        #
        # idea - Decidim::Idea
        # current_user - the user performing the action
        def initialize(idea, current_user)
          @idea = idea
          @current_user = current_user
        end

        # Executes the command. Broadcasts these events:
        #
        # - :ok when everything is valid.
        # - :invalid if the form wasn't valid and we couldn't proceed.
        #
        # Returns nothing.
        def call
          return broadcast(:invalid) if idea.published?

          @idea = Decidim.traceability.perform_action!(
            :publish,
            idea,
            current_user,
            visibility: "all"
          ) do
            idea.publish!
            increment_score
            idea
          end
          broadcast(:ok, idea)
        end

        private

        attr_reader :idea, :current_user

        def increment_score
          if idea.user_group
            Decidim::Gamification.increment_score(idea.user_group, :ideas)
          else
            Decidim::Gamification.increment_score(idea.author, :ideas)
          end
        end
      end
    end
  end
end
