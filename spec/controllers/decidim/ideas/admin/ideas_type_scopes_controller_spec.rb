# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Ideas
    module Admin
      describe IdeasTypeScopesController, type: :controller do
        routes { Decidim::Ideas::AdminEngine.routes }

        let(:organization) { create(:organization) }
        let(:admin_user) { create(:user, :confirmed, :admin, organization: organization) }
        let(:user) { create(:user, :confirmed, organization: organization) }
        let(:idea_type) do
          create(:ideas_type, organization: organization)
        end
        let(:idea_type_scope) do
          create(:ideas_type_scope, type: idea_type)
        end

        let(:valid_attributes) do
          attrs = attributes_for(:ideas_type_scope, type: idea_type)
          {
            decidim_scopes_id: attrs[:scope],
            supports_required: attrs[:supports_required]
          }
        end

        let(:invalid_attributes) do
          attrs = attributes_for(:ideas_type_scope, type: idea_type)
          {
            decidim_scopes_id: attrs[:scope],
            supports_required: nil
          }
        end

        before do
          request.env["decidim.current_organization"] = organization
        end

        context "when new" do
          context "and admin user" do
            before do
              sign_in admin_user, scope: :user
            end

            it "gets loaded" do
              get :new, params: { ideas_type_id: idea_type.id }
              expect(flash[:alert]).to be_nil
              expect(response).to have_http_status(:ok)
            end
          end

          context "and regular user" do
            before do
              sign_in user, scope: :user
            end

            it "access denied" do
              get :new, params: { ideas_type_id: idea_type.id }
              expect(flash[:alert]).not_to be_empty
              expect(response).to have_http_status(:found)
            end
          end
        end

        context "when create" do
          context "and admin user" do
            before do
              sign_in admin_user, scope: :user
            end

            it "gets created" do
              expect do
                post :create,
                     params: {
                       ideas_type_id: idea_type.id,
                       ideas_type_scope: valid_attributes
                     }
              end.to change(IdeasTypeScope, :count).by(1)
            end

            it "fails creation" do
              expect do
                post :create,
                     params: {
                       ideas_type_id: idea_type.id,
                       ideas_type_scope: invalid_attributes
                     }
              end.not_to change(IdeasTypeScope, :count)
            end
          end

          context "and regular user" do
            before do
              sign_in user, scope: :user
            end

            it "access denied" do
              post :create,
                   params: {
                     ideas_type_id: idea_type.id,
                     ideas_type_scope: valid_attributes
                   }
              expect(flash[:alert]).not_to be_empty
              expect(response).to have_http_status(:found)
            end
          end
        end

        context "when edit" do
          context "and admin user" do
            before do
              sign_in admin_user, scope: :user
            end

            it "gets loaded" do
              get :edit,
                  params: {
                    ideas_type_id: idea_type.id,
                    id: idea_type_scope.to_param
                  }
              expect(flash[:alert]).to be_nil
              expect(response).to have_http_status(:ok)
            end
          end

          context "and regular user" do
            before do
              sign_in user, scope: :user
            end

            it "access denied" do
              get :edit,
                  params: {
                    ideas_type_id: idea_type.id,
                    id: idea_type_scope.to_param
                  }
              expect(flash[:alert]).not_to be_empty
              expect(response).to have_http_status(:found)
            end
          end
        end

        context "when update" do
          context "and admin user" do
            before do
              sign_in admin_user, scope: :user
            end

            it "gets updated" do
              patch :update,
                    params: {
                      ideas_type_id: idea_type.to_param,
                      id: idea_type_scope.to_param,
                      ideas_type_scope: valid_attributes
                    }
              expect(flash[:alert]).to be_nil

              idea_type_scope.reload
              expect(idea_type_scope.supports_required).to eq(valid_attributes[:supports_required])
            end

            it "fails update" do
              patch :update,
                    params: {
                      ideas_type_id: idea_type.to_param,
                      id: idea_type_scope.to_param,
                      ideas_type_scope: invalid_attributes
                    }
              expect(flash[:alert]).not_to be_empty
            end
          end

          context "and regular user" do
            before do
              sign_in user, scope: :user
            end

            it "access denied" do
              patch :update,
                    params: {
                      ideas_type_id: idea_type.to_param,
                      id: idea_type_scope.to_param,
                      ideas_type_scope: valid_attributes
                    }
              expect(flash[:alert]).not_to be_empty
              expect(response).to have_http_status(:found)
            end
          end
        end

        context "when destroy" do
          context "and admin user" do
            before do
              sign_in admin_user
            end

            it "removes the idea type if not used" do
              delete :destroy,
                     params: {
                       ideas_type_id: idea_type.id,
                       id: idea_type_scope.to_param
                     }

              scope = IdeasTypeScope.find_by(id: idea_type_scope.id)
              expect(scope).to be_nil
            end

            it "fails if the idea type scope is being used" do
              create(:idea, organization: organization, scoped_type: idea_type_scope)

              expect do
                delete :destroy,
                       params: {
                         ideas_type_id: idea_type.id,
                         id: idea_type_scope.to_param
                       }
              end.not_to change(IdeasTypeScope, :count)
            end
          end

          context "and regular user" do
            before do
              sign_in user, scope: :user
            end

            it "access denied" do
              delete :destroy,
                     params: {
                       ideas_type_id: idea_type.id,
                       id: idea_type_scope.to_param
                     }
              expect(flash[:alert]).not_to be_empty
              expect(response).to have_http_status(:found)
            end
          end
        end
      end
    end
  end
end
