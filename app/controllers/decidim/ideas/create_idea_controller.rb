# frozen_string_literal: true

module Decidim
  module Ideas
    require "wicked"

    # Controller in charge of managing the create idea wizard.
    class CreateIdeaController < Decidim::Ideas::ApplicationController
      layout "layouts/decidim/idea_creation"

      include Wicked::Wizard
      include Decidim::FormFactory
      include IdeaHelper
      include TypeSelectorOptions
      include SingleIdeaType

      helper Decidim::Admin::IconLinkHelper
      helper IdeaHelper
      helper_method :similar_ideas
      helper_method :scopes
      helper_method :current_idea
      helper_method :idea_type

      steps :select_idea_type,
            :initial_data,
            :check_duplicates,
            :additional_data,
            :finish

      def show
        enforce_permission_to :create, :idea
        send("#{step}_step", idea: cached_idea)
      end

      def update
        enforce_permission_to :create, :idea
        send("#{step}_step", params)
      end

      private

      def select_idea_type_step(_parameters)
        @form = form(Decidim::Ideas::SelectIdeaTypeForm).instance
        # session[:idea] = {}
        delete_cached_idea

        return redirect_to next_wizard_path if single_active_idea_type?

        render_wizard unless performed?
      end

      def initial_data_step(parameters)
        @form = build_form(Decidim::Ideas::InitialDataForm, parameters)
        render_wizard
      end

      def check_duplicates_step(parameters)
        @form = build_form(Decidim::Ideas::InitialDataForm, parameters)

        return redirect_to previous_wizard_path(validate_form: true) unless @form.valid?
        return redirect_to next_wizard_path if similar_ideas.empty?

        render_wizard unless performed?
      end

      def additional_data_step(parameters)
        @form = build_form(Decidim::Ideas::IdeaForm, parameters)
        @form.attachment = form(AttachmentForm).from_params({})

        render_wizard
      end

      def finish_step(parameters)
        @form = build_form(Decidim::Ideas::IdeaForm, parameters)
        return redirect_to previous_wizard_path(validate_form: true) unless @form.valid?
        # return render_wizard if session_idea.has_key?(:id)
        return render_wizard if cached_idea.has_key?(:id)

        CreateIdea.call(@form, current_user) do
          on(:ok) do |idea|
            update_cached_idea({id: idea.id})
            # session[:idea][:id] = idea.id
            render_wizard
          end

          on(:invalid) do |idea|
            logger.fatal "Failed creating idea: #{idea.errors.full_messages.join(", ")}" if idea
            redirect_to previous_wizard_path(validate_form: true)
          end
        end
      end

      def similar_ideas
        @similar_ideas ||= Decidim::Ideas::SimilarIdeas.for(current_organization, @form).all
      end

      def build_form(klass, parameters)
        @form = if single_idea_type?
                  form(klass).from_params(parameters.except(:id).merge(type_id: current_organization_ideas_type.first.id), extra_context)
                else
                  form(klass).from_params(parameters.except(:id), extra_context)
                end

        attributes = @form.attributes_with_values
        update_cached_idea(attributes)
        # session[:idea] = session_idea.merge(attributes)
        @form.valid? if params[:validate_form]

        @form
      end

      def extra_context
        return {} unless idea_type_id

        { idea_type: idea_type }
      end

      def scopes
        @scopes ||= @form.available_scopes
      end

      def current_idea
        # Idea.find(session_idea[:id]) if session_idea.has_key?(:id)
        Idea.find(cached_idea[:id]) if cached_idea.has_key?(:id)
      end

      def idea_type
        @idea_type ||= IdeasType.active.find(idea_type_id)
      end

      def idea_type_id
        # session_idea[:type_id] || @form&.type_id
        cached_idea[:type_id] || @form&.type_id
      end

      def session_idea
        session[:idea] ||= {}
        session[:idea].with_indifferent_access
      end

      def cached_idea
        Rails.cache.fetch("ideas/#{session_id}", expires_in: 12.hours) do
          {}
        end.with_indifferent_access
      end

      def delete_cached_idea
        Rails.cache.delete("ideas/#{session_id}")
      end

      def update_cached_idea(attributes)
        idea = cached_idea.merge(attributes)
        Rails.cache.write("ideas/#{session_id}", idea)
      end

      def session_id
        session[:session_id]
      end
    end
  end
end
