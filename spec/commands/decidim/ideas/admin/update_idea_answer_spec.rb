# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Ideas
    module Admin
      describe UpdateIdeaAnswer do
        let(:form_klass) { Decidim::Ideas::Admin::IdeaAnswerForm }

        context "when valid data" do
          it_behaves_like "update an idea answer" do
            context "when the user is an admin" do
              let(:current_user) { create(:user, :admin, organization: idea.organization) }

              it "notifies the followers" do
                follower = create(:user, organization: organization)
                create(:follow, followable: idea, user: follower)

                expect(Decidim::EventsManager)
                  .to receive(:publish)
                  .with(
                    event: "decidim.events.ideas.idea_extended",
                    event_class: Decidim::Ideas::ExtendIdeaEvent,
                    resource: idea,
                    followers: [follower]
                  )

                command.call
              end

              context "when the signature end time is not modified" do
                let(:signature_end_date) { idea.signature_end_date }

                it "doesn't notify the followers" do
                  expect(Decidim::EventsManager).not_to receive(:publish)

                  command.call
                end
              end
            end
          end
        end

        context "when validation failure" do
          let(:organization) { create(:organization) }
          let!(:idea) { create(:idea, organization: organization) }
          let!(:form) do
            form_klass
              .from_model(idea)
              .with_context(current_organization: organization, idea: idea)
          end

          let(:command) { described_class.new(idea, form, idea.author) }

          it "broadcasts invalid" do
            expect(idea).to receive(:valid?)
              .at_least(:once)
              .and_return(false)
            expect { command.call }.to broadcast :invalid
          end
        end
      end
    end
  end
end
