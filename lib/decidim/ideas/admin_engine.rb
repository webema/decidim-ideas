# frozen_string_literal: true

require "rails"
require "active_support/all"
require "decidim/core"

module Decidim
  module Ideas
    # Decidim's Assemblies Rails Admin Engine.
    class AdminEngine < ::Rails::Engine
      isolate_namespace Decidim::Ideas::Admin

      paths["db/migrate"] = nil
      paths["lib/tasks"] = nil

      routes do
        resources :ideas_types, except: :show do
          resource :permissions, controller: "ideas_types_permissions"
          resources :ideas_type_scopes, except: [:index, :show]
        end

        resources :ideas_settings, only: [:edit, :update], controller: "ideas_settings"

        resources :ideas, only: [:index, :edit, :update], param: :slug do
          member do
            get :send_to_technical_validation
            post :publish
            delete :unpublish
            delete :discard
            post :accept
            delete :reject
          end

          collection do
            get :export
          end

          resources :attachments, controller: "idea_attachments"

          resources :committee_requests, only: [:index] do
            member do
              get :approve
              delete :revoke
            end
          end

          resource :permissions, controller: "ideas_permissions"

          resource :answer, only: [:edit, :update]
        end

        scope "/ideas/:idea_slug" do
          resources :components do
            resource :permissions, controller: "component_permissions"
            member do
              put :publish
              put :unpublish
              get :share
            end
            resources :exports, only: :create
          end

          resources :moderations do
            member do
              put :unreport
              put :hide
              put :unhide
            end
            resources :reports, controller: "moderations/reports", only: [:index, :show]
          end
        end

        scope "/ideas/:idea_slug/components/:component_id/manage" do
          Decidim.component_manifests.each do |manifest|
            next unless manifest.admin_engine

            constraints CurrentComponent.new(manifest) do
              mount manifest.admin_engine, at: "/", as: "decidim_admin_idea_#{manifest.name}"
            end
          end
        end
      end

      initializer "decidim_initiaves.admin_menu" do
        Decidim.menu :admin_menu do |menu|
          menu.add_item :ideas,
                        I18n.t("menu.ideas", scope: "decidim.admin"),
                        decidim_admin_ideas.ideas_path,
                        icon_name: "chat",
                        position: 2.4,
                        active: :inclusive,
                        if: allowed_to?(:enter, :space_area, space_name: :ideas)
        end
      end

      initializer "admin_decidim_ideas.admin_components_menu" do
        Decidim.menu :admin_ideas_components_menu do |menu|
          current_participatory_space.components.each do |component|
            caption = translated_attribute(component.name)
            if component.primary_stat.present?
              caption += content_tag(:span, component.primary_stat, class: component.primary_stat.zero? ? "component-counter component-counter--off" : "component-counter")
            end

            menu.add_item [component.manifest_name, component.id].join("_"),
                          caption.html_safe,
                          manage_component_path(component),
                          active: is_active_link?(manage_component_path(component)),
                          if: component.manifest.admin_engine # && user_role_config.component_is_accessible?(component.manifest_name)
          end
        end
      end

      initializer "admin_decidim_idea.admin_menu" do
        Decidim.menu :admin_idea_menu do |menu|
          menu.add_item :edit_idea,
                        I18n.t("menu.information", scope: "decidim.admin"),
                        decidim_admin_ideas.edit_idea_path(current_participatory_space),
                        active: is_active_link?(decidim_admin_ideas.edit_idea_path(current_participatory_space)),
                        if: allowed_to?(:edit, :idea, idea: current_participatory_space)

          # menu.add_item :idea_committee_requests,
          #               I18n.t("menu.committee_members", scope: "decidim.admin"),
          #               decidim_admin_ideas.idea_committee_requests_path(current_participatory_space),
          #               active: is_active_link?(decidim_admin_ideas.idea_committee_requests_path(current_participatory_space)),
          #               if: current_participatory_space.promoting_committee_enabled? && allowed_to?(:manage_membership, :idea, idea: current_participatory_space)

          menu.add_item :components,
                        I18n.t("menu.components", scope: "decidim.admin"),
                        decidim_admin_ideas.components_path(current_participatory_space),
                        active: is_active_link?(decidim_admin_ideas.components_path(current_participatory_space)),
                        if: allowed_to?(:read, :component, idea: current_participatory_space),
                        submenu: { target_menu: :admin_ideas_components_menu, options: { container_options: { id: "components-list" } } }

          menu.add_item :idea_attachments,
                        I18n.t("menu.attachments", scope: "decidim.admin"),
                        decidim_admin_ideas.idea_attachments_path(current_participatory_space),
                        active: is_active_link?(decidim_admin_ideas.idea_attachments_path(current_participatory_space)),
                        if: allowed_to?(:read, :attachment, idea: current_participatory_space)

          menu.add_item :moderations,
                        I18n.t("menu.moderations", scope: "decidim.admin"),
                        decidim_admin_ideas.moderations_path(current_participatory_space),
                        active: is_active_link?(decidim_admin_ideas.moderations_path(current_participatory_space)),
                        if: allowed_to?(:read, :moderation)
        end
      end

      initializer "admin_decidim_ideas.admin_menu" do
        Decidim.menu :admin_ideas_menu do |menu|
          menu.add_item :ideas,
                        I18n.t("menu.ideas", scope: "decidim.admin"),
                        decidim_admin_ideas.ideas_path,
                        position: 1.0,
                        active: is_active_link?(decidim_admin_ideas.ideas_path),
                        if: allowed_to?(:index, :idea)

          menu.add_item :ideas_types,
                        I18n.t("menu.ideas_types", scope: "decidim.admin"),
                        decidim_admin_ideas.ideas_types_path,
                        active: is_active_link?(decidim_admin_ideas.ideas_types_path),
                        if: allowed_to?(:manage, :idea_type)

          menu.add_item :ideas_settings,
                        I18n.t("menu.ideas_settings", scope: "decidim.admin"),
                        decidim_admin_ideas.edit_ideas_setting_path(
                          Decidim::IdeasSettings.find_or_create_by!(
                            organization: current_organization
                          )
                        ),
                        active: is_active_link?(
                          decidim_admin_ideas.edit_ideas_setting_path(
                            Decidim::IdeasSettings.find_or_create_by!(organization: current_organization)
                          )
                        ),
                        if: allowed_to?(:update, :ideas_settings)
        end
      end
    end
  end
end
