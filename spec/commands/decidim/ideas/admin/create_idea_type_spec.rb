# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Ideas
    module Admin
      describe CreateIdeaType do
        let(:form_klass) { IdeaTypeForm }

        describe "successfull creation" do
          it_behaves_like "create an idea type", true
        end

        describe "Validation failure" do
          let(:organization) { create(:organization) }
          let(:user) { create(:user, organization: organization) }
          let!(:idea_type) do
            build(:ideas_type, organization: organization)
          end
          let(:form) do
            form_klass
              .from_model(idea_type)
              .with_context(current_organization: organization)
          end

          let(:errors) do
            ActiveModel::Errors.new(idea_type)
                               .tap { |e| e.add(:banner_image, "upload error") }
          end
          let(:command) { described_class.new(form, user) }

          it "broadcasts invalid" do
            expect(IdeasType).to receive(:new).at_least(:once).and_return(idea_type)
            expect(idea_type).to receive(:persisted?)
              .at_least(:once)
              .and_return(false)

            expect { command.call }.to broadcast :invalid
          end
        end
      end
    end
  end
end
