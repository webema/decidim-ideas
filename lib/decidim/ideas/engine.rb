# frozen_string_literal: true

require "rails"
require "active_support/all"
require "decidim/core"
require "decidim/ideas/current_locale"
require "decidim/ideas/ideas_filter_form_builder"
require "decidim/ideas/idea_slug"
require "decidim/ideas/query_extensions"

module Decidim
  module Ideas
    # Decidim"s Ideas Rails Engine.
    class Engine < ::Rails::Engine
      isolate_namespace Decidim::Ideas

      routes do
        get "/idea_types/search", to: "idea_types#search", as: :idea_types_search
        get "/idea_type_scopes/search", to: "ideas_type_scopes#search", as: :idea_type_scopes_search
        # get "/idea_type_signature_types/search", to: "ideas_type_signature_types#search", as: :idea_type_signature_types_search

        resources :create_idea

        get "ideas/archived", to: "ideas#archived", as: :archived_ideas

        get "ideas/:idea_id", to: redirect { |params, _request|
          idea = Decidim::Idea.find(params[:idea_id])
          idea ? "/ideas/#{idea.slug}" : "/404"
        }, constraints: { idea_id: /[0-9]+/ }

        get "/ideas/:idea_id/f/:component_id", to: redirect { |params, _request|
          idea = Decidim::Idea.find(params[:idea_id])
          idea ? "/ideas/#{idea.slug}/f/#{params[:component_id]}" : "/404"
        }, constraints: { idea_id: /[0-9]+/ }

        resources :ideas, param: :slug, only: [:index, :show, :edit, :update], path: "ideas" do
          # resources :idea_signatures
          member do
            get :authorization_sign_modal, to: "authorization_sign_modals#show"
            get :print, to: "ideas#print", as: "print"
            get :send_to_technical_validation, to: "ideas#send_to_technical_validation"
            put :like
            put :unlike
          end

          # resource :idea_vote, only: [:create, :destroy]
          resource :widget, only: :show, path: "embed"
          # resources :committee_requests, only: [:new] do
          #   collection do
          #     get :spawn
          #   end
          #   member do
          #     get :approve
          #     delete :revoke
          #   end
          # end
          resources :versions, only: [:show, :index]
        end

        scope "/ideas/:idea_slug/f/:component_id" do
          Decidim.component_manifests.each do |manifest|
            next unless manifest.engine

            constraints CurrentComponent.new(manifest) do
              mount manifest.engine, at: "/", as: "decidim_idea_#{manifest.name}"
            end
          end
        end
      end

      initializer "decidim_ideas.content_blocks" do
        Decidim.content_blocks.register(:homepage, :highlighted_ideas) do |content_block|
          content_block.cell = "decidim/ideas/content_blocks/highlighted_ideas"
          content_block.public_name_key = "decidim.ideas.content_blocks.highlighted_ideas.name"
          content_block.settings_form_cell = "decidim/ideas/content_blocks/highlighted_ideas_settings_form"

          content_block.settings do |settings|
            settings.attribute :max_results, type: :integer, default: 4
            settings.attribute :order, type: :string, default: "default"
          end
        end
      end

      initializer "decidim_ideas.add_cells_view_paths" do
        Cell::ViewModel.view_paths << File.expand_path("#{Decidim::Ideas::Engine.root}/app/cells")
        Cell::ViewModel.view_paths << File.expand_path("#{Decidim::Ideas::Engine.root}/app/views") # for partials
      end

      initializer "decidim_ideas.menu" do
        Decidim.menu :menu do |menu|
          menu.add_item :ideas,
                        I18n.t("menu.ideas", scope: "decidim"),
                        decidim_ideas.ideas_path,
                        position: 2.4,
                        active: :inclusive
        end
      end

      initializer "decidim_ideas.badges" do
        Decidim::Gamification.register_badge(:ideas) do |badge|
          badge.levels = [1, 5, 15, 30, 50]

          badge.valid_for = [:user, :user_group]

          badge.reset = lambda { |model|
            case model
            when User
              Decidim::Idea.where(
                author: model,
                user_group: nil
              ).published.count
            when UserGroup
              Decidim::Idea.where(
                user_group: model
              ).published.count
            end
          }
        end
      end

      initializer "decidim_ideas.query_extensions" do
        Decidim::Api::QueryType.include QueryExtensions
      end

      initializer "decidim_ideas.webpacker.assets_path" do
        Decidim.register_assets_path File.expand_path("app/packs", root)
      end

      initializer "decidim_ideas.preview_mailer" do
        # Load in mailer previews for apps to use in development.
        # We need to make sure we call `Preview.all` before requiring our
        # previews, otherwise any previews the app attempts to add need to be
        # manually required.
        if Rails.env.development? || Rails.env.test?
          ActionMailer::Preview.all

          Dir[root.join("spec/mailers/previews/**/*_preview.rb")].each do |file|
            require_dependency file
          end
        end
      end
    end
  end
end
