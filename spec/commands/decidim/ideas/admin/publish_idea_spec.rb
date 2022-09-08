# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Ideas
    module Admin
      describe PublishIdea do
        subject { described_class.new(idea, user) }

        let(:idea) { create :idea, :created }
        let(:user) { create :user, :admin, :confirmed, organization: idea.organization }

        context "when the idea is already published" do
          let(:idea) { create :idea }

          it "broadcasts :invalid" do
            expect { subject.call }.to broadcast(:invalid)
          end
        end

        context "when everything is ok" do
          it "publishes the idea" do
            expect { subject.call }.to change(idea, :state).from("created").to("published")
          end

          it "traces the action", versioning: true do
            expect(Decidim.traceability)
              .to receive(:perform_action!)
              .with(:publish, idea, user, visibility: "all")
              .and_call_original

            expect { subject.call }.to change(Decidim::ActionLog, :count)
            action_log = Decidim::ActionLog.last
            expect(action_log.version).to be_present
          end

          it "increments the author's score" do
            expect { subject.call }.to change { Decidim::Gamification.status_for(idea.author, :ideas).score }.by(1)
          end
        end
      end
    end
  end
end
