# frozen_string_literal: true

module Decidim
  module Ideas
    # A command with all the business logic when a user or organization unvotes an idea.
    class UnvoteIdea < Decidim::Command
      # Public: Initializes the command.
      #
      # idea   - A Decidim::Idea object.
      # current_user - The current user.
      def initialize(idea, current_user)
        @idea = idea
        @current_user = current_user
      end

      # Executes the command. Broadcasts these events:
      #
      # - :ok when everything is valid, together with the idea.
      # - :invalid if the form wasn't valid and we couldn't proceed.
      #
      # Returns nothing.
      def call
        destroy_idea_vote
        broadcast(:ok, @idea)
      end

      private

      def destroy_idea_vote
        Idea.transaction do
          @idea.votes.where(author: @current_user).destroy_all
        end
      end
    end
  end
end
