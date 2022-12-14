# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Ideas
    module Admin
      describe CommitteeRequestsController, type: :controller do
        routes { Decidim::Ideas::AdminEngine.routes }

        let(:organization) { create(:organization) }
        let(:idea) { create(:idea, :created, organization: organization) }
        let(:admin_user) { create(:user, :admin, :confirmed, organization: organization) }
        let(:user) { create(:user, :confirmed, organization: organization) }

        before do
          request.env["decidim.current_organization"] = organization
        end

        context "when GET index" do
          context "and administrators" do
            before do
              sign_in admin_user, scope: :user
            end

            it "action is allowed" do
              get :index, params: { idea_slug: idea.to_param }
              expect(flash[:alert]).to be_nil
              expect(response).to have_http_status(:ok)
            end
          end

          context "and other users" do
            before do
              sign_in user, scope: :user
            end

            it "action is not allowed" do
              get :index, params: { idea_slug: idea.to_param }
              expect(flash[:alert]).not_to be_nil
              expect(response).to have_http_status(:found)
            end
          end

          context "and author" do
            before do
              sign_in idea.author, scope: :user
            end

            it "action is allowed" do
              get :index, params: { idea_slug: idea.to_param }
              expect(flash[:alert]).to be_nil
              expect(response).to have_http_status(:ok)
            end
          end

          context "and committee members" do
            before do
              sign_in idea.committee_members.approved.first.user, scope: :user
            end

            it "action is allowed" do
              get :index, params: { idea_slug: idea.to_param }
              expect(flash[:alert]).to be_nil
              expect(response).to have_http_status(:ok)
            end
          end
        end

        context "when GET approve" do
          let(:membership_request) { create(:ideas_committee_member, idea: idea, state: "requested") }

          context "and Owner" do
            before do
              sign_in idea.author, scope: :user
            end

            it "request gets approved" do
              get :approve, params: { idea_slug: membership_request.idea.to_param, id: membership_request.to_param }
              membership_request.reload
              expect(membership_request).to be_accepted
            end
          end

          context "and other users" do
            let(:user) { create(:user, :confirmed, organization: organization) }

            before do
              create(:authorization, user: user)
              sign_in user, scope: :user
            end

            it "Action is denied" do
              get :approve, params: { idea_slug: membership_request.idea.to_param, id: membership_request.to_param }
              expect(flash[:alert]).not_to be_empty
              expect(response).to have_http_status(:found)
            end
          end

          context "and Admin" do
            before do
              sign_in admin_user, scope: :user
            end

            it "request gets approved" do
              get :approve, params: { idea_slug: membership_request.idea.to_param, id: membership_request.to_param }
              membership_request.reload
              expect(membership_request).to be_accepted
            end
          end
        end

        context "when DELETE revoke" do
          let(:membership_request) { create(:ideas_committee_member, idea: idea, state: "requested") }

          context "and Owner" do
            before do
              sign_in idea.author, scope: :user
            end

            it "request gets approved" do
              delete :revoke, params: { idea_slug: membership_request.idea.to_param, id: membership_request.to_param }
              membership_request.reload
              expect(membership_request).to be_rejected
            end
          end

          context "and Other users" do
            let(:user) { create(:user, :confirmed, organization: organization) }

            before do
              create(:authorization, user: user)
              sign_in user, scope: :user
            end

            it "Action is denied" do
              delete :revoke, params: { idea_slug: membership_request.idea.to_param, id: membership_request.to_param }
              expect(flash[:alert]).not_to be_empty
              expect(response).to have_http_status(:found)
            end
          end

          context "and Admin" do
            before do
              sign_in admin_user, scope: :user
            end

            it "request gets approved" do
              delete :revoke, params: { idea_slug: membership_request.idea.to_param, id: membership_request.to_param }
              membership_request.reload
              expect(membership_request).to be_rejected
            end
          end
        end
      end
    end
  end
end
