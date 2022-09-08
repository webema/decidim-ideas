# frozen_string_literal: true

require "spec_helper"

describe Decidim::Ideas::Admin::IdeasController, type: :controller do
  routes { Decidim::Ideas::AdminEngine.routes }

  let(:user) { create(:user, :confirmed, organization: organization) }
  let(:admin_user) { create(:user, :admin, :confirmed, organization: organization) }
  let(:organization) { create(:organization) }
  let!(:idea) { create(:idea, organization: organization) }
  let!(:created_idea) { create(:idea, :created, organization: organization) }

  before do
    request.env["decidim.current_organization"] = organization
  end

  context "when index" do
    context "and Users without ideas" do
      before do
        sign_in user, scope: :user
      end

      it "idea list is not allowed" do
        get :index
        expect(flash[:alert]).not_to be_empty
        expect(response).to have_http_status(:found)
      end
    end

    context "and anonymous users do" do
      it "idea list is not allowed" do
        get :index
        expect(flash[:alert]).not_to be_empty
        expect(response).to have_http_status(:found)
      end
    end

    context "and admin users" do
      before do
        sign_in admin_user, scope: :user
      end

      it "idea list is allowed" do
        get :index
        expect(flash[:alert]).to be_nil
        expect(response).to have_http_status(:ok)
      end
    end

    context "and idea author" do
      before do
        sign_in idea.author, scope: :user
      end

      it "idea list is allowed" do
        get :index
        expect(flash[:alert]).to be_nil
        expect(response).to have_http_status(:ok)
      end
    end

    describe "and promotal committee members" do
      before do
        sign_in idea.committee_members.approved.first.user, scope: :user
      end

      it "idea list is allowed" do
        get :index
        expect(flash[:alert]).to be_nil
        expect(response).to have_http_status(:ok)
      end
    end
  end

  context "when edit" do
    context "and Users without ideas" do
      before do
        sign_in user, scope: :user
      end

      it "are not allowed" do
        get :edit, params: { slug: idea.to_param }
        expect(flash[:alert]).not_to be_empty
        expect(response).to have_http_status(:found)
      end
    end

    context "and anonymous users" do
      it "are not allowed" do
        get :edit, params: { slug: idea.to_param }
        expect(flash[:alert]).not_to be_empty
        expect(response).to have_http_status(:found)
      end
    end

    context "and admin users" do
      before do
        sign_in admin_user, scope: :user
      end

      it "are allowed" do
        get :edit, params: { slug: idea.to_param }
        expect(flash[:alert]).to be_nil
        expect(response).to have_http_status(:ok)
      end
    end

    context "and idea author" do
      before do
        sign_in idea.author, scope: :user
      end

      it "are allowed" do
        get :edit, params: { slug: idea.to_param }
        expect(flash[:alert]).to be_nil
        expect(response).to have_http_status(:ok)
      end
    end

    context "and promotal committee members" do
      before do
        sign_in idea.committee_members.approved.first.user, scope: :user
      end

      it "are allowed" do
        get :edit, params: { slug: idea.to_param }
        expect(flash[:alert]).to be_nil
        expect(response).to have_http_status(:ok)
      end
    end
  end

  context "when update" do
    let(:valid_attributes) do
      attrs = attributes_for(:idea, organization: organization)
      attrs[:signature_end_date] = I18n.l(attrs[:signature_end_date], format: :decidim_short)
      attrs[:signature_start_date] = I18n.l(attrs[:signature_start_date], format: :decidim_short)
      attrs
    end

    context "and Users without ideas" do
      before do
        sign_in user, scope: :user
      end

      it "are not allowed" do
        put :update,
            params: {
              slug: idea.to_param,
              idea: valid_attributes
            }
        expect(flash[:alert]).not_to be_empty
        expect(response).to have_http_status(:found)
      end
    end

    context "and anonymous users do" do
      it "are not allowed" do
        put :update,
            params: {
              slug: idea.to_param,
              idea: valid_attributes
            }
        expect(flash[:alert]).not_to be_empty
        expect(response).to have_http_status(:found)
      end
    end

    context "and admin users" do
      before do
        sign_in admin_user, scope: :user
      end

      it "are allowed" do
        put :update,
            params: {
              slug: idea.to_param,
              idea: valid_attributes
            }
        expect(flash[:alert]).to be_nil
        expect(response).to have_http_status(:found)
      end
    end

    context "and idea author" do
      context "and idea published" do
        before do
          sign_in idea.author, scope: :user
        end

        it "are not allowed" do
          put :update,
              params: {
                slug: idea.to_param,
                idea: valid_attributes
              }
          expect(flash[:alert]).not_to be_nil
          expect(response).to have_http_status(:found)
        end
      end

      context "and idea created" do
        let(:idea) { create(:idea, :created, organization: organization) }

        before do
          sign_in idea.author, scope: :user
        end

        it "are allowed" do
          put :update,
              params: {
                slug: idea.to_param,
                idea: valid_attributes
              }
          expect(flash[:alert]).to be_nil
          expect(response).to have_http_status(:found)
        end
      end
    end

    context "and promotal committee members" do
      context "and idea published" do
        before do
          sign_in idea.committee_members.approved.first.user, scope: :user
        end

        it "are not allowed" do
          put :update,
              params: {
                slug: idea.to_param,
                idea: valid_attributes
              }
          expect(flash[:alert]).not_to be_nil
          expect(response).to have_http_status(:found)
        end
      end

      context "and idea created" do
        let(:idea) { create(:idea, :created, organization: organization) }

        before do
          sign_in idea.committee_members.approved.first.user, scope: :user
        end

        it "are allowed" do
          put :update,
              params: {
                slug: idea.to_param,
                idea: valid_attributes
              }
          expect(flash[:alert]).to be_nil
          expect(response).to have_http_status(:found)
        end
      end
    end
  end

  context "when GET send_to_technical_validation" do
    context "and Idea in created state" do
      context "and has not enough committee members" do
        before do
          created_idea.author.confirm
          sign_in created_idea.author, scope: :user
        end

        it "does not pass to technical validation phase" do
          created_idea.type.update(minimum_committee_members: 4)
          get :send_to_technical_validation, params: { slug: created_idea.to_param }

          created_idea.reload
          expect(created_idea).not_to be_validating
        end

        it "does pass to technical validation phase" do
          created_idea.type.update(minimum_committee_members: 3)
          get :send_to_technical_validation, params: { slug: created_idea.to_param }

          created_idea.reload
          expect(created_idea).to be_validating
        end
      end

      context "and User is not the owner of the idea" do
        let(:other_user) { create(:user, organization: organization) }

        before do
          sign_in other_user, scope: :user
        end

        it "Raises an error" do
          get :send_to_technical_validation, params: { slug: created_idea.to_param }
          expect(flash[:alert]).not_to be_empty
          expect(response).to have_http_status(:found)
        end
      end

      context "and User is the owner of the idea. It is in created state" do
        before do
          created_idea.author.confirm
          sign_in created_idea.author, scope: :user
        end

        it "Passes to technical validation phase" do
          get :send_to_technical_validation, params: { slug: created_idea.to_param }

          created_idea.reload
          expect(created_idea).to be_validating
        end
      end
    end

    context "and Idea in discarded state" do
      let!(:discarded_idea) { create(:idea, :discarded, organization: organization) }

      before do
        sign_in discarded_idea.author, scope: :user
      end

      it "Passes to technical validation phase" do
        get :send_to_technical_validation, params: { slug: discarded_idea.to_param }

        discarded_idea.reload
        expect(discarded_idea).to be_validating
      end
    end

    context "and Idea not in created or discarded state (published)" do
      before do
        sign_in idea.author, scope: :user
      end

      it "Raises an error" do
        get :send_to_technical_validation, params: { slug: idea.to_param }
        expect(flash[:alert]).not_to be_empty
        expect(response).to have_http_status(:found)
      end
    end
  end

  context "when POST publish" do
    let!(:idea) { create(:idea, :validating, organization: organization) }

    context "and Idea owner" do
      before do
        sign_in idea.author, scope: :user
      end

      it "Raises an error" do
        post :publish, params: { slug: idea.to_param }
        expect(flash[:alert]).not_to be_empty
        expect(response).to have_http_status(:found)
      end
    end

    context "and Administrator" do
      let!(:admin) { create(:user, :confirmed, :admin, organization: organization) }

      before do
        sign_in admin, scope: :user
      end

      it "idea gets published" do
        post :publish, params: { slug: idea.to_param }
        expect(response).to have_http_status(:found)

        idea.reload
        expect(idea).to be_published
        expect(idea.published_at).not_to be_nil
        expect(idea.signature_start_date).not_to be_nil
        expect(idea.signature_end_date).not_to be_nil
      end
    end
  end

  context "when DELETE unpublish" do
    context "and Idea owner" do
      before do
        sign_in idea.author, scope: :user
      end

      it "Raises an error" do
        delete :unpublish, params: { slug: idea.to_param }
        expect(flash[:alert]).not_to be_empty
        expect(response).to have_http_status(:found)
      end
    end

    context "and Administrator" do
      let(:admin) { create(:user, :confirmed, :admin, organization: organization) }

      before do
        sign_in admin, scope: :user
      end

      it "idea gets unpublished" do
        delete :unpublish, params: { slug: idea.to_param }
        expect(response).to have_http_status(:found)

        idea.reload
        expect(idea).not_to be_published
        expect(idea).to be_discarded
        expect(idea.published_at).to be_nil
      end
    end
  end

  context "when DELETE discard" do
    let(:idea) { create(:idea, :validating, organization: organization) }

    context "and Idea owner" do
      before do
        sign_in idea.author, scope: :user
      end

      it "Raises an error" do
        delete :discard, params: { slug: idea.to_param }
        expect(flash[:alert]).not_to be_empty
        expect(response).to have_http_status(:found)
      end
    end

    context "and Administrator" do
      let(:admin) { create(:user, :confirmed, :admin, organization: organization) }

      before do
        sign_in admin, scope: :user
      end

      it "idea gets discarded" do
        delete :discard, params: { slug: idea.to_param }
        expect(response).to have_http_status(:found)

        idea.reload
        expect(idea).to be_discarded
        expect(idea.published_at).to be_nil
      end
    end
  end

  context "when POST accept" do
    let!(:idea) { create(:idea, :acceptable, signature_type: "any", organization: organization) }

    context "and Idea owner" do
      before do
        sign_in idea.author, scope: :user
      end

      it "Raises an error" do
        post :accept, params: { slug: idea.to_param }
        expect(flash[:alert]).not_to be_empty
        expect(response).to have_http_status(:found)
      end
    end

    context "when Administrator" do
      let!(:admin) { create(:user, :confirmed, :admin, organization: organization) }

      before do
        sign_in admin, scope: :user
      end

      it "idea gets published" do
        post :accept, params: { slug: idea.to_param }
        expect(response).to have_http_status(:found)

        idea.reload
        expect(idea).to be_accepted
      end
    end
  end

  context "when DELETE reject" do
    let!(:idea) { create(:idea, :rejectable, signature_type: "any", organization: organization) }

    context "and Idea owner" do
      before do
        sign_in idea.author, scope: :user
      end

      it "Raises an error" do
        delete :reject, params: { slug: idea.to_param }
        expect(flash[:alert]).not_to be_empty
        expect(response).to have_http_status(:found)
      end
    end

    context "when Administrator" do
      let!(:admin) { create(:user, :confirmed, :admin, organization: organization) }

      before do
        sign_in admin, scope: :user
      end

      it "idea gets rejected" do
        delete :reject, params: { slug: idea.to_param }
        expect(response).to have_http_status(:found)
        expect(flash[:alert]).to be_nil

        idea.reload
        expect(idea).to be_rejected
      end
    end
  end

  context "when GET export_votes" do
    let(:idea) { create(:idea, organization: organization, signature_type: "any") }

    context "and author" do
      before do
        sign_in idea.author, scope: :user
      end

      it "is not allowed" do
        get :export_votes, params: { slug: idea.to_param, format: :csv }
        expect(flash[:alert]).not_to be_empty
        expect(response).to have_http_status(:found)
      end
    end

    context "and promotal committee" do
      before do
        sign_in idea.committee_members.approved.first.user, scope: :user
      end

      it "is not allowed" do
        get :export_votes, params: { slug: idea.to_param, format: :csv }
        expect(flash[:alert]).not_to be_empty
        expect(response).to have_http_status(:found)
      end
    end

    context "and admin user" do
      let!(:vote) { create(:idea_user_vote, idea: idea) }

      before do
        sign_in admin_user, scope: :user
      end

      it "is allowed" do
        get :export_votes, params: { slug: idea.to_param, format: :csv }
        expect(flash[:alert]).to be_nil
        expect(response).to have_http_status(:ok)
      end
    end
  end

  context "when GET export_pdf_signatures" do
    let(:idea) { create(:idea, :with_user_extra_fields_collection, organization: organization) }

    context "and author" do
      before do
        sign_in idea.author, scope: :user
      end

      it "is not allowed" do
        get :export_pdf_signatures, params: { slug: idea.to_param, format: :pdf }
        expect(flash[:alert]).not_to be_empty
        expect(response).to have_http_status(:found)
      end
    end

    context "and admin" do
      before do
        sign_in admin_user, scope: :user
      end

      it "is allowed" do
        get :export_pdf_signatures, params: { slug: idea.to_param, format: :pdf }
        expect(flash[:alert]).to be_nil
        expect(response).to have_http_status(:ok)
      end
    end
  end

  context "when GET export" do
    context "and user" do
      before do
        sign_in user, scope: :user
      end

      it "is not allowed" do
        expect(Decidim::Ideas::ExportIdeasJob).not_to receive(:perform_later).with(user, "CSV", nil)

        get :export, params: { format: :csv }
        expect(flash[:alert]).not_to be_empty
        expect(response).to have_http_status(:found)
      end
    end

    context "and admin" do
      before do
        sign_in admin_user, scope: :user
      end

      it "is allowed" do
        expect(Decidim::Ideas::ExportIdeasJob).to receive(:perform_later).with(admin_user, organization, "csv", nil)

        get :export, params: { format: :csv }
        expect(flash[:alert]).to be_nil
        expect(response).to have_http_status(:found)
      end

      context "when a collection of ids is passed as a parameter" do
        let!(:ideas) { create_list(:idea, 3, organization: organization) }
        let(:collection_ids) { ideas.map(&:id) }

        it "enqueues the job" do
          expect(Decidim::Ideas::ExportIdeasJob).to receive(:perform_later).with(admin_user, organization, "csv", collection_ids)

          get :export, params: { format: :csv, collection_ids: collection_ids }
          expect(flash[:alert]).to be_nil
          expect(response).to have_http_status(:found)
        end
      end
    end
  end
end
