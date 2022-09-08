# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Ideas
    module Admin
      describe UpdateIdeaType do
        let(:form_klass) { IdeaTypeForm }

        context "when valid data" do
          it_behaves_like "update an idea type", true
        end

        context "when validation error" do
          let(:organization) { create(:organization) }
          let(:user) { create(:user, organization: organization) }
          let!(:idea_type) { create(:ideas_type, organization: organization, banner_image: banner_image) }
          let(:banner_image) { upload_test_file(Decidim::Dev.test_file("city2.jpeg", "image/jpeg")) }
          let(:form) do
            form_klass
              .from_model(idea_type)
              .with_context(current_organization: organization)
          end

          let(:command) { described_class.new(idea_type, form, user) }

          it "broadcasts invalid" do
            expect(idea_type).to receive(:valid?)
              .at_least(:once)
              .and_return(false)
            expect { command.call }.to broadcast :invalid
          end
        end
      end
    end
  end
end
