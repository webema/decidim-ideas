# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Ideas
    describe IdeaSignaturesController, type: :controller do
      routes { Decidim::Ideas::Engine.routes }

      let(:organization) { create(:organization) }
      let(:idea_with_user_extra_fields) { create(:idea, :with_user_extra_fields_collection, organization: organization) }
      let(:idea_without_user_extra_fields) { create(:idea, organization: organization) }
      let(:idea) { idea_without_user_extra_fields }

      before do
        request.env["decidim.current_organization"] = organization
      end

      context "when POST create" do
        context "and authorized user" do
          context "and idea with user extra fields required" do
            it "can't vote" do
              sign_in idea_with_user_extra_fields.author, scope: :user
              post :create, params: { idea_slug: idea_with_user_extra_fields.slug, format: :js }
              expect(response).to have_http_status(:unprocessable_entity)
              expect(response.content_type).to eq("text/javascript; charset=utf-8")
            end
          end

          context "and idea without user extra fields required" do
            it "can vote" do
              expect do
                sign_in idea_without_user_extra_fields.author, scope: :user
                post :create, params: { idea_slug: idea_without_user_extra_fields.slug, format: :js }
              end.to change { IdeasVote.where(idea: idea_without_user_extra_fields).count }.by(1)
            end
          end
        end

        context "and Guest users" do
          it "receives unauthorized response" do
            post :create, params: { idea_slug: idea.slug, format: :js }
            expect(response).to have_http_status(:unauthorized)
          end

          it "do not register the vote" do
            expect do
              post :create, params: { idea_slug: idea.slug, format: :js }
            end.not_to(change { IdeasVote.where(idea: idea).count })
          end
        end
      end

      context "when GET show first step" do
        let(:idea) { idea_with_user_extra_fields }

        context "and Authorized user" do
          it "can get first step" do
            sign_in idea.author, scope: :user

            get :show, params: { idea_slug: idea.slug, id: :fill_personal_data }
            expect(subject.helpers.current_idea).to eq(idea)
            expect(subject.helpers.extra_data_legal_information).to eq(idea.scoped_type.type.extra_fields_legal_information)
          end
        end
      end

      context "when GET idea_signatures" do
        context "and idea without user extra fields required" do
          it "action is unavailable" do
            sign_in idea_without_user_extra_fields.author, scope: :user
            expect { get :show, params: { idea_slug: idea_without_user_extra_fields.slug, id: :fill_personal_data } }.to raise_error(Wicked::Wizard::InvalidStepError)
          end
        end
      end
    end
  end
end
