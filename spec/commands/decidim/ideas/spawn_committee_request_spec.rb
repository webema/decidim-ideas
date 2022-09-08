# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Ideas
    describe SpawnCommitteeRequest do
      let(:idea) { create(:idea, :created) }
      let(:current_user) { create(:user, organization: idea.organization) }
      let(:state) { "requested" }
      let(:form) do
        Decidim::Ideas::CommitteeMemberForm
          .from_params(idea_id: idea.id, user_id: current_user.id, state: state)
          .with_context(
            current_organization: idea.organization,
            current_user: current_user
          )
      end
      let(:command) { described_class.new(form, current_user) }

      context "when duplicated request" do
        let!(:committee_request) { create(:ideas_committee_member, user: current_user, idea: idea) }

        it "broadcasts invalid" do
          expect { command.call }.to broadcast :invalid
        end
      end

      context "when everything is ok" do
        it "broadcasts ok" do
          expect { command.call }.to broadcast :ok
        end

        it "notifies author" do
          expect(Decidim::EventsManager)
            .to receive(:publish)
            .with(
              event: "decidim.events.ideas.spawn_committee_request",
              event_class: Decidim::Ideas::SpawnCommitteeRequestEvent,
              resource: idea,
              affected_users: [idea.author],
              force_send: true,
              extra: { applicant: current_user }
            )

          command.call
        end

        it "Creates a committee membership request" do
          expect do
            command.call
          end.to change(IdeasCommitteeMember, :count)
        end

        it "Request state is requested" do
          command.call
          request = IdeasCommitteeMember.last
          expect(request).to be_requested
        end
      end
    end
  end
end
