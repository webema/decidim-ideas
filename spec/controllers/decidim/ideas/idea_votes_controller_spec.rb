# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Ideas
    describe IdeaVotesController, type: :controller do
      routes { Decidim::Ideas::Engine.routes }

      let(:organization) { create(:organization) }
      let(:idea) { create(:idea, organization: organization) }

      before do
        request.env["decidim.current_organization"] = organization
      end

      context "when POST create" do
        context "and Authorized users" do
          it "Authorized users can vote" do
            expect do
              sign_in idea.author, scope: :user
              post :create, params: { idea_slug: idea.slug, format: :js }
            end.to change { IdeasVote.where(idea: idea).count }.by(1)
          end
        end

        context "and guest users" do
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

      context "when destroy" do
        let!(:vote) { create(:idea_user_vote, idea: idea, author: idea.author) }

        context "and authorized users" do
          it "Authorized users can unvote" do
            expect(vote).not_to be_nil

            expect do
              sign_in idea.author, scope: :user
              delete :destroy, params: { idea_slug: idea.slug, format: :js }
            end.to change { IdeasVote.where(idea: idea).count }.by(-1)
          end
        end

        context "and unvote disabled" do
          let(:ideas_type) { create(:ideas_type, :undo_online_signatures_disabled, organization: organization) }
          let(:scope) { create(:ideas_type_scope, type: ideas_type) }
          let(:idea) { create(:idea, organization: organization, scoped_type: scope) }

          it "does not remove the vote" do
            expect do
              sign_in idea.author, scope: :user
              delete :destroy, params: { idea_slug: idea.slug, format: :js }
            end.not_to(change { IdeasVote.where(idea: idea).count })
          end

          it "raises an exception" do
            sign_in idea.author, scope: :user
            delete :destroy, params: { idea_slug: idea.slug, format: :js }
            expect(flash[:alert]).not_to be_empty
            expect(response).to have_http_status(:found)
          end
        end
      end
    end
  end
end
