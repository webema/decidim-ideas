# frozen_string_literal: true

module Decidim
  module Ideas
    # Exposes the idea vote resource so users can vote ideas.
    class IdeaVotesController < Decidim::Ideas::ApplicationController
      include Decidim::Ideas::NeedsIdea
      include Decidim::FormFactory

      before_action :authenticate_user!

      helper IdeaHelper

      # POST /ideas/:idea_id/idea_vote
      def create
        enforce_permission_to :vote, :idea, idea: current_idea

        @form = form(Decidim::Ideas::VoteForm).from_params(
          idea: current_idea,
          signer: current_user
        )

        VoteIdea.call(@form) do
          on(:ok) do
            current_idea.reload
            render :update_buttons_and_counters
          end

          on(:invalid) do
            render json: {
              error: I18n.t("idea_votes.create.error", scope: "decidim.ideas")
            }, status: :unprocessable_entity
          end
        end
      end

      # DELETE /ideas/:idea_id/idea_vote
      def destroy
        enforce_permission_to :unvote, :idea, idea: current_idea

        UnvoteIdea.call(current_idea, current_user) do
          on(:ok) do
            current_idea.reload
            render :update_buttons_and_counters
          end
        end
      end
    end
  end
end
