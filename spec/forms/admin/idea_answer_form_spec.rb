# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Ideas
    module Admin
      describe IdeaAnswerForm do
        subject { described_class.from_model(idea).with_context(context) }

        let(:organization) { create(:organization) }
        let(:ideas_type) { create(:ideas_type, organization: organization) }
        let(:scope) { create(:ideas_type_scope, type: ideas_type) }

        let(:state) { "published" }

        let(:idea) { create(:idea, organization: organization, state: state, scoped_type: scope) }
        let(:user) { create(:user, organization: organization) }

        let(:context) do
          {
            current_user: user,
            current_organization: organization,
            idea: idea
          }
        end

        context "when everything is OK" do
          it { is_expected.to be_valid }
        end

        describe "#signature_dates_required?" do
          subject { described_class.from_model(idea).with_context(context).signature_dates_required? }

          context "when created" do
            let(:state) { "created" }

            it { is_expected.to be(false) }
          end

          context "when published" do
            it { is_expected.to be(true) }
          end
        end
      end
    end
  end
end
