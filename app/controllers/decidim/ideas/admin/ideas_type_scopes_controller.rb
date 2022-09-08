# frozen_string_literal: true

module Decidim
  module Ideas
    module Admin
      # Controller used to manage the available idea type scopes
      class IdeasTypeScopesController < Decidim::Ideas::Admin::ApplicationController
        helper_method :current_idea_type_scope

        # GET /admin/ideas_types/:ideas_type_id/ideas_type_scopes/new
        def new
          enforce_permission_to :create, :idea_type_scope
          @form = idea_type_scope_form.instance
        end

        # POST /admin/ideas_types/:ideas_type_id/ideas_type_scopes
        def create
          enforce_permission_to :create, :idea_type_scope
          @form = idea_type_scope_form
                  .from_params(params, type_id: params[:ideas_type_id])

          CreateIdeaTypeScope.call(@form) do
            on(:ok) do |idea_type_scope|
              flash[:notice] = I18n.t("decidim.ideas.admin.ideas_type_scopes.create.success")
              redirect_to edit_ideas_type_path(idea_type_scope.type)
            end

            on(:invalid) do
              flash.now[:alert] = I18n.t("decidim.ideas.admin.ideas_type_scopes.create.error")
              render :new
            end
          end
        end

        # GET /admin/ideas_types/:ideas_type_id/ideas_type_scopes/:id/edit
        def edit
          enforce_permission_to :edit, :idea_type_scope, idea_type_scope: current_idea_type_scope
          @form = idea_type_scope_form.from_model(current_idea_type_scope)
        end

        # PUT /admin/ideas_types/:ideas_type_id/ideas_type_scopes/:id
        def update
          enforce_permission_to :update, :idea_type_scope, idea_type_scope: current_idea_type_scope
          @form = idea_type_scope_form.from_params(params)

          UpdateIdeaTypeScope.call(current_idea_type_scope, @form) do
            on(:ok) do
              flash[:notice] = I18n.t("decidim.ideas.admin.ideas_type_scopes.update.success")
              redirect_to edit_ideas_type_path(idea_type_scope.type)
            end

            on(:invalid) do
              flash.now[:alert] = I18n.t("decidim.ideas.admin.ideas_type_scopes.update.error")
              render :edit
            end
          end
        end

        # DELETE /admin/ideas_types/:ideas_type_id/ideas_type_scopes/:id
        def destroy
          enforce_permission_to :destroy, :idea_type_scope, idea_type_scope: current_idea_type_scope
          current_idea_type_scope.destroy!

          redirect_to edit_ideas_type_path(current_idea_type_scope.type), flash: {
            notice: I18n.t("decidim.ideas.admin.ideas_type_scopes.destroy.success")
          }
        end

        private

        def current_idea_type_scope
          @current_idea_type_scope ||= IdeasTypeScope.find(params[:id])
        end

        def idea_type_scope_form
          form(Decidim::Ideas::Admin::IdeaTypeScopeForm)
        end
      end
    end
  end
end
