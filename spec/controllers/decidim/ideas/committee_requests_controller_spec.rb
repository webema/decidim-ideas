# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Ideas
    describe CommitteeRequestsController, type: :controller do
      routes { Decidim::Ideas::Engine.routes }

      let(:organization) { create(:organization) }
      let!(:idea) { create(:idea, :created, organization: organization) }
      let(:admin_user) { create(:user, :admin, :confirmed, organization: organization) }
      let(:user) { create(:user, :confirmed, organization: organization) }

      before do
        request.env["decidim.current_organization"] = organization
      end

      context "when GET spawn" do
        let(:user) { create(:user, :confirmed, organization: organization) }

        before do
          create(:authorization, user: user)
          sign_in user, scope: :user
        end

        context "and created idea" do
          it "Membership request is created" do
            expect do
              get :spawn, params: { idea_slug: idea.slug }
            end.to change(IdeasCommitteeMember, :count).by(1)
          end

          it "Duplicated requests finish with an error" do
            expect do
              get :spawn, params: { idea_slug: idea.slug }
            end.to change(IdeasCommitteeMember, :count).by(1)

            expect do
              get :spawn, params: { idea_slug: idea.slug }
            end.not_to change(IdeasCommitteeMember, :count)
          end
        end

        context "and published idea" do
          let!(:published_idea) { create(:idea, :published, organization: organization) }

          it "Membership request is not created" do
            expect do
              get :spawn, params: { idea_slug: published_idea.slug }
            end.not_to change(IdeasCommitteeMember, :count)
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
