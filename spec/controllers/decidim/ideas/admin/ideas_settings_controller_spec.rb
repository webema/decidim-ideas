# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Ideas
    module Admin
      describe IdeasSettingsController, type: :controller do
        routes { Decidim::Ideas::AdminEngine.routes }

        let(:organization) { create(:organization) }
        let(:current_user) { create(:user, :confirmed, :admin, organization: organization) }
        let!(:ideas_settings) { create(:ideas_settings, organization: organization) }

        before do
          request.env["decidim.current_organization"] = organization
          sign_in current_user
        end

        describe "PATCH update" do
          let(:ideas_settings_params) do
            {
              ideas_order: ideas_settings.ideas_order
            }
          end

          it "updates the ideas settings" do
            patch :update, params: { id: ideas_settings.id, ideas_settings: ideas_settings_params }

            expect(response).to redirect_to edit_ideas_setting_path
          end
        end
      end
    end
  end
end
