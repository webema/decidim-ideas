# # frozen_string_literal: true
# TODO delete?

# module Decidim
#   module Ideas
#     require "wicked"

#     class IdeaSignaturesController < Decidim::Ideas::ApplicationController
#       layout "layouts/decidim/idea_signature_creation"

#       include Wicked::Wizard
#       include Decidim::Ideas::NeedsIdea
#       include Decidim::FormFactory

#       prepend_before_action :set_wizard_steps
#       before_action :authenticate_user!

#       helper IdeaHelper

#       helper_method :idea_type, :extra_data_legal_information

#       # GET /ideas/:idea_id/idea_signatures/:step
#       def show
#         enforce_permission_to :sign_idea, :idea, idea: current_idea, signature_has_steps: signature_has_steps?
#         send("#{step}_step", idea_vote_form: session[:idea_vote_form])
#       end

#       # PUT /ideas/:idea_id/idea_signatures/:step
#       def update
#         enforce_permission_to :sign_idea, :idea, idea: current_idea, signature_has_steps: signature_has_steps?
#         send("#{step}_step", params)
#       end

#       # POST /ideas/:idea_id/idea_signatures
#       def create
#         enforce_permission_to :vote, :idea, idea: current_idea

#         @form = form(Decidim::Ideas::VoteForm)
#                 .from_params(
#                   idea: current_idea,
#                   signer: current_user
#                 )

#         VoteIdea.call(@form) do
#           on(:ok) do
#             current_idea.reload
#             render :update_buttons_and_counters
#           end

#           on(:invalid) do
#             render :error_on_vote, status: :unprocessable_entity
#           end
#         end
#       end

#       private

#       def fill_personal_data_step(_unused)
#         @form = form(Decidim::Ideas::VoteForm)
#                 .from_params(
#                   idea: current_idea,
#                   signer: current_user
#                 )

#         session[:idea_vote_form] = {}
#         skip_step unless idea_type.collect_user_extra_fields
#         render_wizard
#       end

#       def sms_phone_number_step(parameters)
#         if parameters.has_key?(:ideas_vote) || !fill_personal_data_step?
#           build_vote_form(parameters)
#         else
#           check_session_personal_data
#         end
#         clear_session_sms_code

#         if @vote_form.invalid?
#           flash[:alert] = I18n.t("personal_data.invalid", scope: "decidim.ideas.idea_votes")
#           jump_to(previous_step)
#         end

#         @form = Decidim::Verifications::Sms::MobilePhoneForm.new
#         render_wizard
#       end

#       def sms_code_step(parameters)
#         check_session_personal_data if fill_personal_data_step?
#         @phone_form = Decidim::Verifications::Sms::MobilePhoneForm.from_params(parameters.merge(user: current_user))
#         @form = Decidim::Verifications::Sms::ConfirmationForm.new
#         render_wizard && return if session_sms_code.present?

#         ValidateMobilePhone.call(@phone_form, current_user) do
#           on(:ok) do |metadata|
#             store_session_sms_code(metadata)
#             render_wizard
#           end

#           on(:invalid) do
#             flash[:alert] = I18n.t("sms_phone.invalid", scope: "decidim.ideas.idea_votes")
#             redirect_to wizard_path(:sms_phone_number)
#           end
#         end
#       end

#       def finish_step(parameters)
#         if parameters.has_key?(:ideas_vote) || !fill_personal_data_step?
#           build_vote_form(parameters)
#         else
#           check_session_personal_data
#         end

#         if sms_step?
#           @confirmation_code_form = Decidim::Verifications::Sms::ConfirmationForm.from_params(parameters)

#           ValidateSmsCode.call(@confirmation_code_form, session_sms_code) do
#             on(:ok) { clear_session_sms_code }

#             on(:invalid) do
#               flash[:alert] = I18n.t("sms_code.invalid", scope: "decidim.ideas.idea_votes")
#               jump_to :sms_code
#               render_wizard && return
#             end
#           end
#         end

#         VoteIdea.call(@vote_form) do
#           on(:ok) do
#             session[:idea_vote_form] = {}
#           end

#           on(:invalid) do |vote|
#             logger.fatal "Failed creating signature: #{vote.errors.full_messages.join(", ")}" if vote
#             flash[:alert] = I18n.t("create.invalid", scope: "decidim.ideas.idea_votes")
#             jump_to previous_step
#           end
#         end

#         render_wizard
#       end

#       def build_vote_form(parameters)
#         @vote_form = form(Decidim::Ideas::VoteForm).from_params(parameters).tap do |form|
#           form.idea = current_idea
#           form.signer = current_user
#         end

#         session[:idea_vote_form] ||= {}
#         session[:idea_vote_form] = session[:idea_vote_form].merge(@vote_form.attributes_with_values.except(:idea, :signer))
#       end

#       def session_vote_form
#         attributes = session[:idea_vote_form].merge(idea: current_idea, signer: current_user)

#         @vote_form = form(Decidim::Ideas::VoteForm).from_params(attributes)
#       end

#       def idea_type
#         @idea_type ||= current_idea&.scoped_type&.type
#       end

#       def extra_data_legal_information
#         @extra_data_legal_information ||= idea_type.extra_fields_legal_information
#       end

#       def check_session_personal_data
#         return if session[:idea_vote_form].present? && session_vote_form&.valid?

#         flash[:alert] = I18n.t("create.error", scope: "decidim.ideas.idea_votes")
#         jump_to(:fill_personal_data)
#       end

#       def store_session_sms_code(metadata)
#         session[:idea_sms_code] = metadata
#       end

#       def session_sms_code
#         session[:idea_sms_code]
#       end

#       def clear_session_sms_code
#         session[:idea_sms_code] = {}
#       end

#       # def sms_step?
#       #   current_idea.validate_sms_code_on_votes?
#       # end

#       # def fill_personal_data_step?
#       #   idea_type.collect_user_extra_fields?
#       # end

#       def set_wizard_steps
#         initial_wizard_steps = [:finish]
#         initial_wizard_steps.unshift(:sms_phone_number, :sms_code) if sms_step?
#         initial_wizard_steps.unshift(:fill_personal_data) if fill_personal_data_step?

#         self.steps = initial_wizard_steps
#       end
#     end
#   end
# end
