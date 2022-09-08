# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Ideas
    describe CreateIdea do
      let(:form_klass) { IdeaForm }

      context "when happy path" do
        it_behaves_like "create an idea"
      end

      context "when invalid data" do
        let(:organization) { create(:organization) }
        let(:idea) { create(:idea, organization: organization) }
        let(:form) do
          form_klass
            .from_model(idea)
            .with_context(
              current_organization: organization,
              idea_type: idea.scoped_type.type
            )
        end

        let(:command) { described_class.new(form, idea.author) }

        it "broadcasts invalid" do
          expect(form).to receive(:title).at_least(:once).and_return nil

          expect { command.call }.to broadcast :invalid
        end
      end

      describe "events" do
        subject do
          described_class.new(form, author)
        end

        let(:scoped_type) { create(:ideas_type_scope) }
        let(:organization) { scoped_type.type.organization }
        let(:author) { create(:user, organization: organization) }
        let(:form) do
          form_klass
            .from_params(form_params)
            .with_context(
              current_organization: organization,
              idea_type: scoped_type.type
            )
        end
        let(:form_params) do
          {
            title: "A reasonable idea title",
            description: "A reasonable idea description",
            type_id: scoped_type.type.id,
            signature_type: "online",
            scope_id: scoped_type.scope.id,
            decidim_user_group_id: nil
          }
        end
        let(:follower) { create(:user, organization: organization) }
        let!(:follow) { create :follow, followable: author, user: follower }

        it "doesn't notify author about committee request" do
          expect(Decidim::EventsManager)
            .not_to receive(:publish)
            .with(
              event: "decidim.events.ideas.spawn_committee_request",
              event_class: Decidim::Ideas::SpawnCommitteeRequest,
              resource: Decidim::Idea.last,
              followers: [author]
            )

          subject.call
        end

        it "notifies the creation" do
          expect(Decidim::EventsManager)
            .to receive(:publish)
            .with(
              event: "decidim.events.ideas.idea_created",
              event_class: Decidim::Ideas::CreateIdeaEvent,
              resource: kind_of(Decidim::Idea),
              followers: [follower]
            )

          subject.call
        end
      end
    end
  end
end
