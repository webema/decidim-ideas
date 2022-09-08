# frozen_string_literal: true

module Decidim
  module Ideas
    module Admin
      # Controller used to manage the available idea types for the current
      # organization.
      class IdeasTypesController < Decidim::Ideas::Admin::ApplicationController
        helper ::Decidim::Admin::ResourcePermissionsHelper
        helper_method :current_idea_type

        # GET /admin/ideas_types
        def index
          enforce_permission_to :index, :idea_type

          @ideas_types = IdeaTypes.for(current_organization)
        end

        # GET /admin/ideas_types/new
        def new
          enforce_permission_to :create, :idea_type
          @form = idea_type_form.instance
        end

        # POST /admin/ideas_types
        def create
          enforce_permission_to :create, :idea_type
          @form = idea_type_form.from_params(params)

          CreateIdeaType.call(@form, current_user) do
            on(:ok) do |idea_type|
              flash[:notice] = I18n.t("decidim.ideas.admin.ideas_types.create.success")
              redirect_to edit_ideas_type_path(idea_type)
            end

            on(:invalid) do
              flash.now[:alert] = I18n.t("decidim.ideas.admin.ideas_types.create.error")
              render :new
            end
          end
        end

        # GET /admin/ideas_types/:id/edit
        def edit
          enforce_permission_to :edit, :idea_type, idea_type: current_idea_type
          @form = idea_type_form
                  .from_model(current_idea_type,
                              idea_type: current_idea_type)
        end

        # PUT /admin/ideas_types/:id
        def update
          enforce_permission_to :update, :idea_type, idea_type: current_idea_type

          @form = idea_type_form
                  .from_params(params, idea_type: current_idea_type)

          UpdateIdeaType.call(current_idea_type, @form, current_user) do
            on(:ok) do
              flash[:notice] = I18n.t("decidim.ideas.admin.ideas_types.update.success")
              redirect_to edit_ideas_type_path(current_idea_type)
            end

            on(:invalid) do
              flash.now[:alert] = I18n.t("decidim.ideas.admin.ideas_types.update.error")
              render :edit
            end
          end
        end

        # DELETE /admin/ideas_types/:id
        def destroy
          enforce_permission_to :destroy, :idea_type, idea_type: current_idea_type

          Decidim.traceability.perform_action!("delete", current_idea_type, current_user) do
            current_idea_type.destroy!
          end

          redirect_to ideas_types_path, flash: {
            notice: I18n.t("decidim.ideas.admin.ideas_types.destroy.success")
          }
        end

        private

        def current_idea_type
          @current_idea_type ||= IdeasType.find(params[:id])
        end

        def idea_type_form
          form(Decidim::Ideas::Admin::IdeaTypeForm)
        end
      end
    end
  end
end
