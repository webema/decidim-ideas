# frozen_string_literal: true

require "spec_helper"

describe Decidim::Ideas::IdeasController, type: :controller do
  routes { Decidim::Ideas::Engine.routes }

  let(:organization) { create(:organization) }
  let!(:idea) { create(:idea, organization: organization) }
  let!(:created_idea) { create(:idea, :created, organization: organization) }

  before do
    request.env["decidim.current_organization"] = organization
  end

  describe "GET index" do
    it "Only returns published ideas" do
      get :index
      expect(subject.helpers.ideas).to include(idea)
      expect(subject.helpers.ideas).not_to include(created_idea)
    end

    context "when no order is given" do
      let(:voted_idea) { create(:idea, organization: organization) }
      let!(:vote) { create(:idea_user_vote, idea: voted_idea) }
      let!(:ideas_settings) { create(:ideas_settings, :most_signed) }

      it "return in the default order" do
        get :index, params: { order: "most_voted" }

        expect(subject.helpers.ideas.first).to eq(voted_idea)
      end
    end

    context "when order by most_voted" do
      let(:voted_idea) { create(:idea, organization: organization) }
      let!(:vote) { create(:idea_user_vote, idea: voted_idea) }

      it "most voted appears first" do
        get :index, params: { order: "most_voted" }

        expect(subject.helpers.ideas.first).to eq(voted_idea)
      end
    end

    context "when order by most recent" do
      let!(:old_idea) { create(:idea, organization: organization, created_at: idea.created_at - 12.months) }

      it "most recent appears first" do
        get :index, params: { order: "recent" }
        expect(subject.helpers.ideas.first).to eq(idea)
      end
    end

    context "when order by most recently published" do
      let!(:old_idea) { create(:idea, organization: organization, published_at: idea.published_at - 12.months) }

      it "most recent appears first" do
        get :index, params: { order: "recently_published" }
        expect(subject.helpers.ideas.first).to eq(idea)
      end
    end

    context "when order by most commented" do
      let(:commented_idea) { create(:idea, organization: organization) }
      let!(:comment) { create(:comment, commentable: commented_idea) }

      it "most commented appears fisrt" do
        get :index, params: { order: "most_commented" }
        expect(subject.helpers.ideas.first).to eq(commented_idea)
      end
    end
  end

  describe "GET show" do
    context "and any user" do
      it "Shows published ideas" do
        get :show, params: { slug: idea.slug }
        expect(subject.helpers.current_idea).to eq(idea)
      end

      it "Returns 404 when there isn't an idea" do
        expect { get :show, params: { slug: "invalid-idea" } }
          .to raise_error(ActiveRecord::RecordNotFound)
      end

      it "Throws exception on non published ideas" do
        get :show, params: { slug: created_idea.slug }
        expect(flash[:alert]).not_to be_empty
        expect(response).to have_http_status(:found)
      end
    end

    context "and idea Owner" do
      before do
        sign_in created_idea.author, scope: :user
      end

      it "Unpublished ideas are shown too" do
        get :show, params: { slug: created_idea.slug }
        expect(subject.helpers.current_idea).to eq(created_idea)
      end
    end
  end

  describe "Edit idea as promoter" do
    before do
      sign_in created_idea.author, scope: :user
    end

    let(:valid_attributes) do
      attrs = attributes_for(:idea, organization: organization)
      attrs[:signature_end_date] = I18n.l(attrs[:signature_end_date], format: :decidim_short)
      attrs[:signature_start_date] = I18n.l(attrs[:signature_start_date], format: :decidim_short)
      attrs[:type_id] = created_idea.type.id
      attrs
    end

    it "edit when user is allowed" do
      get :edit, params: { slug: created_idea.slug }
      expect(flash[:alert]).to be_nil
      expect(response).to have_http_status(:ok)
    end

    context "and update an idea" do
      it "are allowed" do
        put :update,
            params: {
              slug: created_idea.to_param,
              idea: valid_attributes
            }
        expect(flash[:alert]).to be_nil
        expect(response).to have_http_status(:found)
      end
    end

    context "when idea is invalid" do
      it "does not update when title is nil" do
        invalid_attributes = valid_attributes.merge(title: nil)

        put :update,
            params: {
              slug: created_idea.to_param,
              idea: invalid_attributes
            }

        expect(flash[:alert]).not_to be_empty
        expect(response).to have_http_status(:ok)
      end

      context "when the existing idea has attachments and there are other errors on the form" do
        let!(:created_idea) do
          create(
            :idea,
            :created,
            :with_photos,
            :with_documents,
            organization: organization
          )
        end

        include_context "with controller rendering the view" do
          let(:invalid_attributes) do
            valid_attributes.merge(
              title: nil,
              photos: created_idea.photos.map { |a| a.id.to_s },
              documents: created_idea.documents.map { |a| a.id.to_s }
            )
          end

          it "displays the editing form with errors" do
            put :update, params: {
              slug: created_idea.to_param,
              idea: invalid_attributes
            }

            expect(flash[:alert]).not_to be_empty
            expect(response).to have_http_status(:ok)
            expect(subject).to render_template(:edit)
            expect(response.body).to include("An error has occurred")
          end
        end
      end
    end
  end
end
