# frozen_string_literal: true

module Decidim
  module Ideas
    module Admin
      # A command with all the business logic that unpublishes an
      # existing idea.
      class UnpublishIdea < Decidim::Command
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
          return broadcast(:invalid) unless idea.published?

          @idea = Decidim.traceability.perform_action!(
            :unpublish,
            idea,
            current_user
          ) do
            idea.unpublish!
            idea
          end
          broadcast(:ok, idea)
        end

        private

        attr_reader :idea, :current_user
      end
    end
  end
end
