# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Ideas
    describe RevokeMembershipRequest do
      let(:organization) { create(:organization) }
      let!(:idea) { create(:idea, :created, organization: organization) }
      let(:author) { idea.author }
      let(:membership_request) { create(:ideas_committee_member, idea: idea, state: "requested") }
      let(:command) { described_class.new(membership_request) }

      context "when everything is ok" do
        it "broadcasts ok" do
          expect { command.call }.to broadcast :ok
        end

        it "notifies author" do
          expect(Decidim::EventsManager)
            .to receive(:publish)
            .with(
              event: "decidim.events.ideas.revoke_membership_request",
              event_class: Decidim::Ideas::RevokeMembershipRequestEvent,
              resource: idea,
              affected_users: [membership_request.user],
              force_send: true,
              extra: { author: idea.author }
            )

          command.call
        end

        it "revokes committee membership request" do
          expect do
            command.call
          end.to change(membership_request, :state).from("requested").to("rejected")
        end
      end
    end
  end
end
