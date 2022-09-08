# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Ideas
    describe SendIdeaToTechnicalValidation do
      subject { described_class.new(idea, user) }

      let(:idea) { create :idea }
      let(:organization) { idea.organization }
      let(:user) { create :user, :confirmed, organization: organization }
      let!(:admin) { create(:user, :admin, organization: organization) }

      context "when everything is ok" do
        it "sends the idea to technical validation" do
          expect { subject.call }.to change(idea, :state).from("published").to("validating")
        end

        it "traces the action", versioning: true do
          expect(Decidim.traceability)
            .to receive(:perform_action!)
            .with(:send_to_technical_validation, idea, user)
            .and_call_original

          expect { subject.call }.to change(Decidim::ActionLog, :count)
          action_log = Decidim::ActionLog.last
          expect(action_log.version).to be_present
        end

        it "notifies the admins" do
          expect(Decidim::EventsManager)
            .to receive(:publish)
            .once
            .ordered
            .with(
              event: "decidim.events.ideas.idea_sent_to_technical_validation",
              event_class: Decidim::Ideas::IdeaSentToTechnicalValidationEvent,
              force_send: true,
              resource: idea,
              affected_users: a_collection_containing_exactly(admin)
            )

          subject.call
        end
      end
    end
  end
end
