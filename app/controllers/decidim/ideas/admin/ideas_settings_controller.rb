# frozen_string_literal: true

module Decidim
  module Ideas
    module Admin
      # Controller used to manage the ideas settings for the current
      # organization.
      class IdeasSettingsController < Decidim::Ideas::Admin::ApplicationController
        layout "decidim/admin/ideas"

        # GET /admin/ideas_settings/edit
        def edit
          enforce_permission_to :update, :ideas_settings, ideas_settings: current_ideas_settings
          @form = ideas_settings_form.from_model(current_ideas_settings)
        end

        # PUT /admin/ideas_settings
        def update
          enforce_permission_to :update, :ideas_settings, ideas_settings: current_ideas_settings

          @form = ideas_settings_form
                  .from_params(params, ideas_settings: current_ideas_settings)

          UpdateIdeasSettings.call(current_ideas_settings, @form) do
            on(:ok) do
              flash[:notice] = I18n.t("ideas_settings.update.success", scope: "decidim.admin")
              redirect_to edit_ideas_setting_path
            end

            on(:invalid) do
              flash.now[:alert] = I18n.t("ideas_settings.update.error", scope: "decidim.admin")
              render :edit
            end
          end
        end

        private

        def current_ideas_settings
          @current_ideas_settings ||= Decidim::IdeasSettings.find_or_create_by!(organization: current_organization)
        end

        def ideas_settings_form
          form(Decidim::Ideas::Admin::IdeasSettingsForm)
        end
      end
    end
  end
end
