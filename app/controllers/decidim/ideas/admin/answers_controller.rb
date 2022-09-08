# frozen_string_literal: true

module Decidim
  module Ideas
    module Admin
      # Controller used to manage the ideas answers
      class AnswersController < Decidim::Ideas::Admin::ApplicationController
        include Decidim::Ideas::NeedsIdea

        helper Decidim::Ideas::IdeaHelper
        layout "decidim/admin/ideas"

        # GET /admin/ideas/:id/answer/edit
        def edit
          enforce_permission_to :answer, :idea, idea: current_idea
          @form = form(Decidim::Ideas::Admin::IdeaAnswerForm)
                  .from_model(
                    current_idea,
                    idea: current_idea
                  )
        end

        # PUT /admin/ideas/:id/answer
        def update
          enforce_permission_to :answer, :idea, idea: current_idea

          @form = form(Decidim::Ideas::Admin::IdeaAnswerForm)
                  .from_params(params, idea: current_idea)

          UpdateIdeaAnswer.call(current_idea, @form, current_user) do
            on(:ok) do
              flash[:notice] = I18n.t("ideas.update.success", scope: "decidim.ideas.admin")
              redirect_to ideas_path
            end

            on(:invalid) do
              flash[:alert] = I18n.t("ideas.update.error", scope: "decidim.ideas.admin")
              redirect_to edit_idea_answer_path
            end
          end
        end
      end
    end
  end
end
