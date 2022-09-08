# frozen_string_literal: true

require "spec_helper"

describe Decidim::Ideas::Admin::Permissions do
  subject { described_class.new(user, permission_action, context).permissions.allowed? }

  let(:user) { create :user, organization: organization }
  let(:organization) { create :organization }
  let(:idea) { create :idea, organization: organization }
  let(:context) { { idea: idea } }
  let(:permission_action) { Decidim::PermissionAction.new(**action) }
  let(:ideas_settings) { create :ideas_settings, organization: organization }
  let(:action) do
    { scope: :admin, action: action_name, subject: action_subject }
  end

  shared_examples "checks idea state" do |name, valid_trait, invalid_trait|
    let(:action_name) { name }

    context "when idea is #{valid_trait}" do
      let(:idea) { create :idea, valid_trait, organization: organization }

      it { is_expected.to be true }
    end

    context "when idea is not #{valid_trait}" do
      let(:idea) { create :idea, invalid_trait, organization: organization }

      it { is_expected.to be false }
    end
  end

  shared_examples "idea committee action" do
    let(:action_subject) { :idea_committee_member }

    context "when indexing" do
      let(:action_name) { :index }

      it { is_expected.to be true }
    end

    context "when approving" do
      let(:action_name) { :approve }
      let(:context) { { idea: idea, request: request } }

      context "when request is not accepted yet" do
        let(:request) { create :ideas_committee_member, :requested, idea: idea }

        it { is_expected.to be true }
      end

      context "when request is already accepted" do
        let(:request) { create :ideas_committee_member, :accepted, idea: idea }

        it { is_expected.to be false }
      end
    end

    context "when revoking" do
      let(:action_name) { :revoke }
      let(:context) { { idea: idea, request: request } }

      context "when request is not revoked yet" do
        let(:request) { create :ideas_committee_member, :accepted, idea: idea }

        it { is_expected.to be true }
      end

      context "when request is already revoked" do
        let(:request) { create :ideas_committee_member, :rejected, idea: idea }

        it { is_expected.to be false }
      end
    end

    context "when any other condition" do
      let(:action_name) { :foo }

      it_behaves_like "permission is not set"
    end
  end

  context "when the action is not for the admin part" do
    let(:action) do
      { scope: :public, action: :foo, subject: :idea }
    end

    it_behaves_like "permission is not set"
  end

  context "when user is not given" do
    let(:user) { nil }
    let(:action) do
      { scope: :admin, action: :foo, subject: :idea }
    end

    it_behaves_like "permission is not set"
  end

  context "when checking access to space area" do
    let(:action) do
      { scope: :admin, action: :enter, subject: :space_area }
    end
    let(:context) { { space_name: :ideas } }

    context "when user created an idea" do
      let(:idea) { create :idea, author: user, organization: organization }

      before { idea }

      it { is_expected.to be true }
    end

    context "when user promoted an idea" do
      before do
        create :ideas_committee_member, idea: idea, user: user
      end

      it { is_expected.to be true }
    end

    context "when user is admin" do
      let(:user) { create :user, :admin, organization: organization }

      it { is_expected.to be true }
    end

    context "when space name is not set" do
      let(:context) { {} }

      it_behaves_like "permission is not set"
    end
  end

  context "when user is a member of the idea" do
    before do
      create :ideas_committee_member, idea: idea, user: user
    end

    it_behaves_like "idea committee action"

    context "when managing ideas" do
      let(:action_subject) { :idea }

      context "when reading" do
        let(:action_name) { :read }

        before do
          allow(Decidim::Ideas).to receive(:print_enabled).and_return(print_enabled)
        end

        context "when print is disabled" do
          let(:print_enabled) { false }

          it { is_expected.to be false }
        end

        context "when print is enabled" do
          let(:print_enabled) { true }

          it { is_expected.to be true }
        end
      end

      context "when updating" do
        let(:action_name) { :update }

        context "when idea is created" do
          let(:idea) { create :idea, :created, organization: organization }

          it { is_expected.to be true }
        end

        context "when idea is not created" do
          it { is_expected.to be false }
        end
      end

      context "when sending to technical validation" do
        let(:action_name) { :send_to_technical_validation }

        context "when idea is created" do
          let(:idea) { create :idea, :created, organization: organization }

          context "when idea is authored by a user group" do
            let(:user_group) { create :user_group, organization: user.organization, users: [user] }

            before do
              idea.update(decidim_user_group_id: user_group.id)
            end

            it { is_expected.to be true }
          end

          context "when idea has enough approved members" do
            before do
              allow(idea).to receive(:enough_committee_members?).and_return(true)
            end

            it { is_expected.to be true }
          end

          context "when idea has not enough approved members" do
            before do
              allow(idea).to receive(:enough_committee_members?).and_return(false)
            end

            it { is_expected.to be false }
          end
        end

        context "when idea is discarded" do
          let(:idea) { create :idea, :discarded, organization: organization }

          it { is_expected.to be true }
        end

        context "when idea is not created or discarded" do
          it { is_expected.to be false }
        end
      end

      context "when editing" do
        let(:action_name) { :edit }

        it { is_expected.to be true }
      end

      context "when previewing" do
        let(:action_name) { :preview }

        it { is_expected.to be true }
      end

      context "when managing memberships" do
        let(:action_name) { :manage_membership }

        it { is_expected.to be true }
      end

      context "when reading a ideas settings" do
        let(:action_subject) { :ideas_settings }
        let(:action_name) { :update }

        it { is_expected.to be false }
      end

      context "when any other action" do
        let(:action_name) { :foo }

        it { is_expected.to be false }
      end
    end

    context "when managing attachments" do
      let(:action_subject) { :attachment }

      shared_examples "attached to an idea" do |name|
        context "when action is #{name}" do
          let(:action_name) { name }
          let(:context) { { idea: idea, attachment: attachment } }

          context "when attached to an idea" do
            let(:attachment) { create :attachment, attached_to: idea }

            it { is_expected.to be true }
          end

          context "when attached to something else" do
            let(:attachment) { create :attachment }

            it { is_expected.to be false }
          end
        end
      end

      context "when reading" do
        let(:action_name) { :read }

        it { is_expected.to be true }
      end

      context "when creating" do
        let(:action_name) { :create }

        it { is_expected.to be true }
      end

      it_behaves_like "attached to an idea", :update
      it_behaves_like "attached to an idea", :destroy
    end
  end

  context "when user is admin" do
    let(:user) { create :user, :admin, organization: organization }

    it_behaves_like "idea committee action"

    context "when managing attachments" do
      let(:action_subject) { :attachment }
      let(:action_name) { :foo }

      it { is_expected.to be true }
    end

    context "when managing idea types" do
      let(:action_subject) { :idea_type }

      context "when destroying" do
        let(:action_name) { :destroy }
        let(:idea_type) { create :ideas_type }
        let(:organization) { idea_type.organization }
        let(:context) { { idea_type: idea_type } }

        before do
          allow(idea_type).to receive(:scopes).and_return(scopes)
        end

        context "when its scopes are empty" do
          let(:scopes) do
            [
              double(ideas: [])
            ]
          end

          it { is_expected.to be true }
        end

        context "when its scopes are not empty" do
          let(:scopes) do
            [
              double(ideas: [1, 2, 3])
            ]
          end

          it { is_expected.to be false }
        end
      end

      context "when any random action" do
        let(:action_name) { :foo }

        it { is_expected.to be true }
      end
    end

    context "when managing idea type scopes" do
      let(:action_subject) { :idea_type_scope }

      context "when destroying" do
        let(:action_name) { :destroy }
        let(:scope) { create :ideas_type_scope }
        let(:context) { { idea_type_scope: scope } }

        before do
          allow(scope).to receive(:ideas).and_return(ideas)
        end

        context "when it has no ideas" do
          let(:ideas) do
            []
          end

          it { is_expected.to be true }
        end

        context "when it has some ideas" do
          let(:ideas) do
            [1, 2, 3]
          end

          it { is_expected.to be false }
        end
      end

      context "when any random action" do
        let(:action_name) { :foo }

        it { is_expected.to be true }
      end
    end

    context "when managing ideas" do
      let(:action_subject) { :idea }

      context "when reading" do
        let(:action_name) { :read }

        before do
          allow(Decidim::Ideas).to receive(:print_enabled).and_return(print_enabled)
        end

        context "when print is disabled" do
          let(:print_enabled) { false }

          it { is_expected.to be false }
        end

        context "when print is enabled" do
          let(:print_enabled) { true }

          it { is_expected.to be true }
        end
      end

      it_behaves_like "checks idea state", :publish, :validating, :published
      it_behaves_like "checks idea state", :unpublish, :published, :validating
      it_behaves_like "checks idea state", :discard, :validating, :published
      it_behaves_like "checks idea state", :export_votes, :offline, :online
      it_behaves_like "checks idea state", :export_pdf_signatures, :published, :validating

      context "when accepting the idea" do
        let(:action_name) { :accept }
        let(:idea) { create :idea, organization: organization, signature_end_date: 2.days.ago }
        let(:goal_reached) { true }

        before do
          allow(idea).to receive(:supports_goal_reached?).and_return(goal_reached)
        end

        it { is_expected.to be true }

        context "when the idea is not published" do
          let(:idea) { create :idea, :validating, organization: organization }

          it { is_expected.to be false }
        end

        context "when the idea signature time is not finished" do
          let(:idea) { create :idea, signature_end_date: 2.days.from_now, organization: organization }

          it { is_expected.to be false }
        end

        context "when the idea percentage is not complete" do
          let(:goal_reached) { false }

          it { is_expected.to be false }
        end
      end

      context "when rejecting the idea" do
        let(:action_name) { :reject }
        let(:idea) { create :idea, organization: organization, signature_end_date: 2.days.ago }
        let(:goal_reached) { false }

        before do
          allow(idea).to receive(:supports_goal_reached?).and_return(goal_reached)
        end

        it { is_expected.to be true }

        context "when the idea is not published" do
          let(:idea) { create :idea, :validating, organization: organization }

          it { is_expected.to be false }
        end

        context "when the idea signature time is not finished" do
          let(:idea) { create :idea, signature_end_date: 2.days.from_now, organization: organization }

          it { is_expected.to be false }
        end

        context "when the idea percentage is complete" do
          let(:goal_reached) { true }

          it { is_expected.to be false }
        end
      end
    end

    context "when reading a ideas settings" do
      let(:action_subject) { :ideas_settings }
      let(:action_name) { :update }

      it { is_expected.to be true }
    end
  end

  context "when any other condition" do
    let(:action) do
      { scope: :admin, action: :foo, subject: :bar }
    end

    it_behaves_like "permission is not set"
  end
end
