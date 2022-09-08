# frozen_string_literal: true

module Decidim
  module Ideas
    module Admin
      require "csv"

      # Controller used to manage the ideas
      class IdeasController < Decidim::Ideas::Admin::ApplicationController
        include Decidim::Ideas::NeedsIdea
        include Decidim::Ideas::SingleIdeaType
        include Decidim::Ideas::TypeSelectorOptions
        include Decidim::Ideas::Admin::Filterable

        helper ::Decidim::Admin::ResourcePermissionsHelper
        helper Decidim::Ideas::IdeaHelper

        # GET /admin/ideas
        def index
          enforce_permission_to :list, :idea
          @ideas = filtered_collection
        end

        # GET /admin/ideas/:id/edit
        def edit
          enforce_permission_to :edit, :idea, idea: current_idea

          form_attachment_model = form(AttachmentForm).from_model(current_idea.attachments.first)
          @form = form(Decidim::Ideas::Admin::IdeaForm)
                  .from_model(
                    current_idea,
                    idea: current_idea
                  )
          @form.attachment = form_attachment_model

          render layout: "decidim/admin/idea"
        end

        # PUT /admin/ideas/:id
        def update
          enforce_permission_to :update, :idea, idea: current_idea

          params[:id] = params[:slug]
          @form = form(Decidim::Ideas::Admin::IdeaForm)
                  .from_params(params, idea: current_idea)

          Decidim::Ideas::Admin::UpdateIdea.call(current_idea, @form, current_user) do
            on(:ok) do |idea|
              flash[:notice] = I18n.t("ideas.update.success", scope: "decidim.ideas.admin")
              redirect_to edit_idea_path(idea)
            end

            on(:invalid) do
              flash.now[:alert] = I18n.t("ideas.update.error", scope: "decidim.ideas.admin")
              render :edit, layout: "decidim/admin/idea"
            end
          end
        end

        # POST /admin/ideas/:id/publish
        def publish
          enforce_permission_to :publish, :idea, idea: current_idea

          PublishIdea.call(current_idea, current_user) do
            on(:ok) do
              redirect_to decidim_admin_ideas.edit_idea_path(current_idea)
            end
          end
        end

        # DELETE /admin/ideas/:id/unpublish
        def unpublish
          enforce_permission_to :unpublish, :idea, idea: current_idea

          UnpublishIdea.call(current_idea, current_user) do
            on(:ok) do
              redirect_to decidim_admin_ideas.edit_idea_path(current_idea)
            end
          end
        end

        # DELETE /admin/ideas/:id/discard
        def discard
          enforce_permission_to :discard, :idea, idea: current_idea
          current_idea.discarded!
          redirect_to decidim_admin_ideas.edit_idea_path(current_idea)
        end

        # POST /admin/ideas/:id/accept
        def accept
          enforce_permission_to :accept, :idea, idea: current_idea
          current_idea.accepted!
          redirect_to decidim_admin_ideas.edit_idea_path(current_idea)
        end

        # DELETE /admin/ideas/:id/reject
        def reject
          enforce_permission_to :reject, :idea, idea: current_idea
          current_idea.rejected!
          redirect_to decidim_admin_ideas.edit_idea_path(current_idea)
        end

        # GET /admin/ideas/:id/send_to_technical_validation
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

        # GET /admin/ideas/export
        def export
          enforce_permission_to :export, :ideas

          Decidim::Ideas::ExportIdeasJob.perform_later(
            current_user,
            current_organization,
            params[:format] || default_format,
            params[:collection_ids].presence&.map(&:to_i)
          )

          flash[:notice] = t("decidim.admin.exports.notice")

          redirect_back(fallback_location: ideas_path)
        end

        # GET /admin/ideas/:id/export_votes
        def export_votes
          enforce_permission_to :export_votes, :idea, idea: current_idea

          votes = current_idea.votes.map(&:sha1)
          csv_data = CSV.generate(headers: false) do |csv|
            votes.each do |sha1|
              csv << [sha1]
            end
          end

          respond_to do |format|
            format.csv { send_data csv_data, file_name: "votes.csv" }
          end
        end

        # GET /admin/ideas/:id/export_pdf_signatures.pdf
        def export_pdf_signatures
          enforce_permission_to :export_pdf_signatures, :idea, idea: current_idea

          @votes = current_idea.votes

          output = render_to_string(
            pdf: "votes_#{current_idea.id}",
            layout: "decidim/admin/ideas_votes",
            template: "decidim/ideas/admin/ideas/export_pdf_signatures",
            format: [:pdf]
          )
          output = pdf_signature_service.new(pdf: output).signed_pdf if pdf_signature_service

          respond_to do |format|
            format.pdf do
              send_data(output, filename: "votes_#{current_idea.id}.pdf", type: "application/pdf")
            end
          end
        end

        private

        def collection
          @collection ||= ManageableIdeas.for(current_user)
        end

        def pdf_signature_service
          @pdf_signature_service ||= Decidim.pdf_signature_service.to_s.safe_constantize
        end

        def default_format
          "json"
        end
      end
    end
  end
end
