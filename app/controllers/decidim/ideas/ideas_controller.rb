# frozen_string_literal: true

module Decidim
  module Ideas
    # This controller contains the logic regarding participants ideas
    class IdeasController < Decidim::Ideas::ApplicationController
      include ParticipatorySpaceContext
      participatory_space_layout only: [:show]

      helper Decidim::WidgetUrlsHelper
      helper Decidim::AttachmentsHelper
      helper Decidim::FiltersHelper
      helper Decidim::OrdersHelper
      helper Decidim::ResourceHelper
      helper Decidim::IconHelper
      helper Decidim::Comments::CommentsHelper
      helper Decidim::Admin::IconLinkHelper
      helper Decidim::ResourceReferenceHelper
      helper PaginateHelper
      helper IdeaHelper
      include IdeaSlug
      include FilterResource
      include Paginable
      include Decidim::FormFactory
      include Decidim::Ideas::Orderable
      include TypeSelectorOptions
      include NeedsIdea
      include SingleIdeaType

      helper_method :collection, :ideas, :filter, :stats
      helper_method :idea_type

      # GET /ideas
      def index
        enforce_permission_to :list, :idea
      end

      # GET /ideas/:id
      def show
        enforce_permission_to :read, :idea, idea: current_idea

        set_last_content_edit
      end

      # GET /ideas/:id/send_to_technical_validation
      def send_to_technical_validation
        enforce_permission_to :send_to_technical_validation, :idea, idea: current_idea

        SendIdeaToTechnicalValidation.call(current_idea, current_user) do
          on(:ok) do
            redirect_to EngineRouter.main_proxy(current_idea).ideas_path(idea_slug: nil), flash: {
              notice: I18n.t(
                "success",
                scope: "decidim.ideas.admin.ideas.edit"
              )
            }
          end
        end
      end

      # GET /ideas/:slug/edit
      def edit
        enforce_permission_to :edit, :idea, idea: current_idea
        form_attachment_model = form(AttachmentForm).from_model(current_idea.attachments.first)
        @form = form(Decidim::Ideas::EditIdeaForm)
                .from_model(
                  current_idea,
                  idea: current_idea
                )
        @form.attachment = form_attachment_model

        render layout: "decidim/idea"
      end

      # PUT /ideas/:id
      def update
        enforce_permission_to :update, :idea, idea: current_idea

        params[:id] = params[:slug]
        @form = form(Decidim::Ideas::EditIdeaForm)
                .from_params(params, idea_type: current_idea.type, idea: current_idea)

        UpdateIdea.call(current_idea, @form, current_user) do
          on(:ok) do |idea|
            flash[:notice] = I18n.t("success", scope: "decidim.ideas.update")
            redirect_to idea_path(idea)
          end

          on(:invalid) do
            flash.now[:alert] = I18n.t("error", scope: "decidim.ideas.update")
            render :edit, layout: "decidim/idea"
          end
        end
      end

      def like
        enforce_permission_to :like, :idea, idea: current_idea

        current_idea.liked_by current_user
        render layout: false
      end

      def unlike
        enforce_permission_to :like, :idea, idea: current_idea

        current_idea.unliked_by current_user
        render layout: false
      end

      private

      alias current_idea current_participatory_space

      def current_participatory_space
        @current_participatory_space ||= Idea.find(id_from_slug(params[:slug]))
      end

      def current_participatory_space_manifest
        @current_participatory_space_manifest ||= Decidim.find_participatory_space_manifest(:ideas)
      end

      def ideas
        @ideas = search.result.includes(:scoped_type)
        @ideas = reorder(@ideas)
        @ideas = paginate(@ideas)
      end

      alias collection ideas

      def search_collection
        Idea
          .includes(scoped_type: [:scope])
          .joins("JOIN decidim_users ON decidim_users.id = decidim_ideas.decidim_author_id")
          .where(organization: current_organization)
      end

      def default_filter_params
        {
          search_text_cont: "",
          with_any_state: default_filter_state_params,
          with_any_type: default_filter_type_params,
          author: "any",
          with_any_scope: default_filter_scope_params,
          with_any_area: default_filter_area_params
        }
      end

      def default_filter_type_params
        %w(all) + Decidim::IdeasType.where(organization: current_organization).pluck(:id).map(&:to_s)
      end

      def default_filter_scope_params
        %w(all global) + current_organization.scopes.pluck(:id).map(&:to_s)
      end

      def default_filter_area_params
        %w(all) + current_organization.areas.pluck(:id).map(&:to_s)
      end

      def default_filter_state_params
        %w(open) + Decidim::Idea.states.keys.last(5)
      end

      def stats
        @stats ||= IdeaStatsPresenter.new(idea: current_idea)
      end

      def set_last_content_edit
        object_changes = PaperTrail::Version.arel_table[:object_changes]
        versions = current_participatory_space.versions.where(event: 'update')
        @last_content_edit = versions.where(object_changes.matches("%#{"title:"}%"))
                                     .or(versions.where(object_changes.matches("%#{"description:"}%")))
                                     .or(versions.where(object_changes.matches("%#{"source:"}%")))
                                     .order(created_at: :desc).last
      end
    end
  end
end
