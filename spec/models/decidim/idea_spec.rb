# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe Idea do
    subject { idea }

    let(:organization) { create(:organization) }
    let(:idea) { build :idea }

    let(:ideas_type_minimum_committee_members) { 2 }
    let(:ideas_type) do
      create(
        :ideas_type,
        organization: organization,
        minimum_committee_members: ideas_type_minimum_committee_members
      )
    end
    let(:scoped_type) { create(:ideas_type_scope, type: ideas_type) }

    include_examples "has reference"

    context "when created idea" do
      let(:idea) { create(:idea, :created) }
      let(:administrator) { create(:user, :admin, organization: idea.organization) }
      let(:message_delivery) { instance_double(ActionMailer::MessageDelivery) }
      let(:offline_type) { create(:ideas_type, :online_signature_disabled, organization: organization) }
      let(:offline_scope) { create(:ideas_type_scope, type: offline_type) }

      before do
        allow(message_delivery).to receive(:deliver_later)
      end

      it "is versioned" do
        expect(idea).to be_versioned
      end

      it "enforces signature types specified in the type" do
        online_idea = build(:idea, :created, organization: organization, scoped_type: offline_scope, signature_type: "online")
        offline_idea = build(:idea, :created, organization: organization, scoped_type: offline_scope, signature_type: "offline")

        expect(online_idea).to be_invalid
        expect(offline_idea).to be_valid
      end

      it "Creation is notified by email" do
        expect(Decidim::Ideas::IdeasMailer).to receive(:notify_creation)
          .at_least(:once)
          .at_most(:once)
          .and_return(message_delivery)
        idea = build(:idea, :created)
        idea.save!
      end
    end

    context "when published idea" do
      let(:published_idea) { build :idea }
      let(:online_allowed_type) { create(:ideas_type, :online_signature_enabled, organization: organization) }
      let(:online_allowed_scope) { create(:ideas_type_scope, type: online_allowed_type) }

      it "is valid" do
        expect(published_idea).to be_valid
      end

      it "does not enforce signature type if the type was updated" do
        idea = build(:idea, :published, organization: organization, scoped_type: online_allowed_scope, signature_type: "online")

        expect(idea.save).to be_truthy

        online_allowed_type.update!(signature_type: "offline")

        expect(idea).to be_valid
      end

      it "unpublish!" do
        published_idea.unpublish!

        expect(published_idea).to be_discarded
        expect(published_idea.published_at).to be_nil
      end

      it "signature_interval_defined?" do
        expect(published_idea).to have_signature_interval_defined
      end

      context "when mailing" do
        let(:message_delivery) { instance_double(ActionMailer::MessageDelivery) }

        before do
          allow(message_delivery).to receive(:deliver_later)
        end

        it "Acceptation is notified by email" do
          expect(Decidim::Ideas::IdeasMailer).to receive(:notify_state_change)
            .at_least(:once)
            .and_return(message_delivery)
          published_idea.accepted!
        end

        it "Rejection is notified by email" do
          expect(Decidim::Ideas::IdeasMailer).to receive(:notify_state_change)
            .at_least(:once)
            .and_return(message_delivery)
          published_idea.rejected!
        end
      end
    end

    context "when validating idea" do
      let(:validating_idea) do
        build(:idea,
              state: "validating",
              published_at: nil,
              signature_start_date: nil,
              signature_end_date: nil)
      end

      it "is valid" do
        expect(validating_idea).to be_valid
      end

      it "publish!" do
        validating_idea.publish!
        expect(validating_idea).to have_signature_interval_defined
        expect(validating_idea.published_at).not_to be_nil
      end

      context "when mailing" do
        let(:message_delivery) { instance_double(ActionMailer::MessageDelivery) }

        before do
          allow(message_delivery).to receive(:deliver_later)
        end

        it "publication is notified by email" do
          expect(Decidim::Ideas::IdeasMailer).to receive(:notify_state_change)
            .at_least(:once)
            .and_return(message_delivery)
          validating_idea.published!
        end

        it "Discard is notified by email" do
          expect(Decidim::Ideas::IdeasMailer).to receive(:notify_state_change)
            .at_least(:once)
            .and_return(message_delivery)
          validating_idea.discarded!
        end
      end
    end

    context "when has_authorship?" do
      let(:idea) { create(:idea) }
      let(:user) { create(:user) }
      let(:pending_committee_member) { create(:ideas_committee_member, :requested, idea: idea) }
      let(:rejected_committee_member) { create(:ideas_committee_member, :rejected, idea: idea) }

      it "returns true for the idea author" do
        expect(idea).to have_authorship(idea.author)
      end

      it "returns true for aproved promotal committee members" do
        expect(idea).not_to have_authorship(pending_committee_member.user)
        expect(idea).not_to have_authorship(rejected_committee_member.user)

        expect(idea.committee_members.approved).to be_any

        idea.committee_members.approved.each do |m|
          expect(idea).to have_authorship(m.user)
        end
      end

      it "returns false for any other user" do
        expect(idea).not_to have_authorship(user)
      end
    end

    describe "signatures calculations" do
      let!(:idea) { create(:idea, signature_type: signature_type) }
      let(:scope_id) { idea.scope.id.to_s }
      let!(:other_scope_for_type) { create(:ideas_type_scope, type: idea.type) }

      context "with only online ideas" do
        let(:signature_type) { "online" }

        it "ignores any value in offline_votes attribute" do
          idea.update(offline_votes: { scope_id => idea.scoped_type.supports_required, "total" => idea.scoped_type.supports_required },
                            online_votes: { scope_id => idea.scoped_type.supports_required / 2, "total" => idea.scoped_type.supports_required / 2 })
          expect(idea.percentage).to eq(50)
          expect(idea).not_to be_supports_goal_reached
        end

        it "can't be greater than 100" do
          idea.update(online_votes: { scope_id => idea.scoped_type.supports_required, "total" => idea.scoped_type.supports_required * 2 })
          expect(idea.percentage).to eq(100)
          expect(idea).to be_supports_goal_reached
        end
      end

      context "with face-to-face support too" do
        let(:signature_type) { "any" }

        it "returns the percentage of votes reached" do
          online_votes = idea.scoped_type.supports_required / 4
          offline_votes = idea.scoped_type.supports_required / 4
          idea.update(offline_votes: { scope_id => offline_votes, "total" => offline_votes },
                            online_votes: { scope_id => online_votes, "total" => online_votes })
          expect(idea.percentage).to eq(50)
          expect(idea).not_to be_supports_goal_reached
        end

        it "can't be greater than 100" do
          online_votes = idea.scoped_type.supports_required * 4
          offline_votes = idea.scoped_type.supports_required * 4
          idea.update(offline_votes: { scope_id => offline_votes, "total" => offline_votes },
                            online_votes: { scope_id => online_votes, "total" => online_votes })
          expect(idea.percentage).to eq(100)
          expect(idea).to be_supports_goal_reached
        end
      end
    end

    describe "#minimum_committee_members" do
      subject { idea.minimum_committee_members }

      let(:committee_members_fallback_setting) { 1 }
      let(:idea) { create(:idea, organization: organization, scoped_type: scoped_type) }

      before do
        allow(Decidim::Ideas).to(
          receive(:minimum_committee_members).and_return(committee_members_fallback_setting)
        )
      end

      context "when setting defined in type" do
        it { is_expected.to eq ideas_type_minimum_committee_members }
      end

      context "when setting not set" do
        let(:ideas_type_minimum_committee_members) { nil }

        it { is_expected.to eq committee_members_fallback_setting }
      end
    end

    describe "#enough_committee_members?" do
      subject { idea.enough_committee_members? }

      let(:ideas_type_minimum_committee_members) { 2 }
      let(:idea) { create(:idea, organization: organization, scoped_type: scoped_type) }

      before { idea.committee_members.destroy_all }

      context "when enough members" do
        before { create_list(:ideas_committee_member, ideas_type_minimum_committee_members, idea: idea) }

        it { is_expected.to be true }
      end

      context "when not enough members" do
        before { create_list(:ideas_committee_member, ideas_type_minimum_committee_members - 1, idea: idea) }

        it { is_expected.to be false }
      end
    end

    describe "sorting" do
      subject(:sorter) { described_class.ransack("s" => "supports_count desc") }

      before do
        create(:idea, organization: organization, signature_type: "offline")
        create(:idea, organization: organization, signature_type: "offline", offline_votes: { "total" => 4 })
        create(:idea, organization: organization, signature_type: "online", online_votes: { "total" => 5 })
        create(:idea, organization: organization, signature_type: "online", online_votes: { "total" => 3 })
        create(:idea, organization: organization, signature_type: "any", online_votes: { "total" => 1 })
        create(:idea, organization: organization, signature_type: "any", online_votes: { "total" => 5 }, offline_votes: { "total" => 3 })
      end

      it "sorts ideas by supports count" do
        expect(sorter.result.map(&:supports_count)).to eq([8, 5, 4, 3, 1, 0])
      end
    end
  end
end
