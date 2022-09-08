# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Ideas
    module Admin
      describe UnpublishIdea do
        subject { described_class.new(idea, user) }

        let(:idea) { create :idea }
        let(:user) { create :user, :admin, :confirmed, organization: idea.organization }

        context "when the idea is already unpublished" do
          let(:idea) { create :idea, :created }

          it "broadcasts :invalid" do
            expect { subject.call }.to broadcast(:invalid)
          end
        end

        context "when everything is ok" do
          it "unpublishes the idea" do
            expect { subject.call }.to change(idea, :state).from("published").to("discarded")
          end

          it "traces the action", versioning: true do
            expect(Decidim.traceability)
              .to receive(:perform_action!)
              .with(:unpublish, idea, user)
              .and_call_original

            expect { subject.call }.to change(Decidim::ActionLog, :count)
            action_log = Decidim::ActionLog.last
            expect(action_log.version).to be_present
          end
        end
      end
    end
  end
end
