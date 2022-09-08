# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Ideas
    module Admin
      describe UpdateIdeasSettings do
        subject { described_class.new(ideas_settings, form) }

        let(:organization) { create :organization }
        let(:user) { create :user, :admin, :confirmed, organization: organization }
        let(:ideas_settings) { create :ideas_settings, organization: organization }
        let(:ideas_order) { "date" }
        let(:form) do
          double(
            invalid?: invalid,
            current_user: user,
            ideas_order: ideas_order
          )
        end
        let(:invalid) { false }

        context "when the form is not valid" do
          let(:invalid) { true }

          it "is not valid" do
            expect { subject.call }.to broadcast(:invalid)
          end
        end

        context "when the form is valid" do
          it "broadcasts ok" do
            expect { subject.call }.to broadcast(:ok)
          end

          it "updates the ideas settings" do
            subject.call
            expect(ideas_settings.ideas_order).to eq(ideas_order)
          end
        end
      end
    end
  end
end
