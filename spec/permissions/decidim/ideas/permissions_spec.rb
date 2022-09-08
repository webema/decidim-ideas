# frozen_string_literal: true

require "spec_helper"

describe Decidim::Ideas::Permissions do
  subject { described_class.new(user, permission_action, context).permissions.allowed? }

  let(:user) { create :user, organization: organization }
  let(:organization) { create :organization }
  let(:idea) { create(:idea, organization: organization) }
  let(:context) { {} }
  let(:permission_action) { Decidim::PermissionAction.new(**action) }

  shared_examples "votes permissions" do
    let(:organization) { create(:organization, available_authorizations: authorizations) }
    let(:authorizations) { %w(dummy_authorization_handler another_dummy_authorization_handler) }
    let(:idea) { create(:idea, organization: organization) }
    let(:context) do
      { idea: idea }
    end
    let(:votes_enabled?) { true }

    before do
      allow(idea).to receive(:votes_enabled?).and_return(votes_enabled?)
    end

    context "when idea has votes disabled" do
      let(:votes_enabled?) { false }

      it { is_expected.to be false }
    end

    context "when user belongs to another organization" do
      let(:user) { create :user }

      it { is_expected.to be false }
    end

    context "when user has already voted the idea" do
      before do
        create(:idea_user_vote, idea: idea, author: user)
      end

      it { is_expected.to be false }
    end

    context "when user has verified user groups" do
      before do
        create :user_group, :verified, users: [user], organization: user.organization
      end

      it { is_expected.to be true }
    end

    context "when the idea type has permissions to vote" do
      before do
        idea.type.create_resource_permission(
          permissions: {
            "vote" => {
              "authorization_handlers" => {
                "dummy_authorization_handler" => { "options" => {} },
                "another_dummy_authorization_handler" => { "options" => {} }
              }
            }
          }
        )
      end

      context "when user is not verified" do
        it { is_expected.to be false }
      end

      context "when user is not fully verified" do
        before do
          create(:authorization, name: "dummy_authorization_handler", user: user, granted_at: 2.seconds.ago)
        end

        it { is_expected.to be false }
      end

      context "when user is fully verified" do
        before do
          create(:authorization, name: "dummy_authorization_handler", user: user, granted_at: 2.seconds.ago)
          create(:authorization, name: "another_dummy_authorization_handler", user: user, granted_at: 2.seconds.ago)
        end

        it { is_expected.to be true }
      end
    end
  end

  context "when the action is for the admin part" do
    let(:action) do
      { scope: :admin, action: :foo, subject: :idea }
    end

    it_behaves_like "delegates permissions to", Decidim::Ideas::Admin::Permissions
  end

  context "when reading an idea" do
    let(:idea) { create(:idea, :discarded, organization: organization) }
    let(:action) do
      { scope: :public, action: :read, subject: :idea }
    end
    let(:context) do
      { idea: idea }
    end

    context "when idea is published" do
      let(:idea) { create(:idea, :published, organization: organization) }

      it { is_expected.to be true }
    end

    context "when idea is rejected" do
      let(:idea) { create(:idea, :rejected, organization: organization) }

      it { is_expected.to be true }
    end

    context "when idea is accepted" do
      let(:idea) { create(:idea, :accepted, organization: organization) }

      it { is_expected.to be true }
    end

    context "when user is admin" do
      let(:user) { create :user, :admin, organization: organization }

      it { is_expected.to be true }
    end

    context "when user is author of the idea" do
      let(:idea) { create(:idea, author: user, organization: organization) }

      it { is_expected.to be true }
    end

    context "when user is committee member of the idea" do
      before do
        create(:ideas_committee_member, idea: idea, user: user)
      end

      it { is_expected.to be true }
    end

    context "when any other condition" do
      it { is_expected.to be false }
    end
  end

  context "when listing committee members of the idea as author" do
    let(:idea) { create(:idea, organization: organization, author: user) }
    let(:action) do
      { scope: :public, action: :index, subject: :idea_committee_member }
    end
    let(:context) do
      { idea: idea }
    end

    it { is_expected.to be true }
  end

  context "when approving committee member of the idea as author" do
    let(:idea) { create(:idea, organization: organization, author: user) }
    let(:action) do
      { scope: :public, action: :approve, subject: :idea_committee_member }
    end
    let(:context) do
      { idea: idea }
    end

    it { is_expected.to be true }
  end

  context "when revoking committee member of the idea as author" do
    let(:idea) { create(:idea, organization: organization, author: user) }
    let(:action) do
      { scope: :public, action: :revoke, subject: :idea_committee_member }
    end
    let(:context) do
      { idea: idea }
    end

    it { is_expected.to be true }
  end

  context "when sending idea to technical validation as author" do
    let(:idea) { create(:idea, state: :created, organization: organization) }
    let(:action) do
      { scope: :public, action: :send_to_technical_validation, subject: :idea }
    end
    let(:context) do
      { idea: idea }
    end

    it { is_expected.to be true }
  end

  context "when creating an idea" do
    let(:action) do
      { scope: :public, action: :create, subject: :idea }
    end

    context "when creation is enabled" do
      before do
        allow(Decidim::Ideas)
          .to receive(:creation_enabled)
          .and_return(true)
      end

      it { is_expected.to be false }

      context "when authorizations are not required" do
        before do
          allow(Decidim::Ideas)
            .to receive(:do_not_require_authorization)
            .and_return(true)
        end

        it { is_expected.to be true }
      end

      context "when user is authorized" do
        before do
          create :authorization, :granted, user: user
        end

        it { is_expected.to be true }
      end

      context "when user belongs to a verified user group" do
        before do
          create :user_group, :verified, users: [user], organization: user.organization
        end

        it { is_expected.to be true }
      end
    end

    context "when creation is not enabled" do
      before do
        allow(Decidim::Ideas)
          .to receive(:creation_enabled)
          .and_return(false)
      end

      it { is_expected.to be false }
    end
  end

  context "when managing an idea" do
    let(:action_subject) { :idea }

    context "when editing" do
      let(:action_name) { :edit }
      let(:action) do
        { scope: :public, action: :edit, subject: :idea }
      end
      let(:context) do
        { idea: idea }
      end

      context "when idea is not created" do
        let(:idea) { create(:idea, author: user, organization: organization) }

        it { is_expected.to be false }
      end

      context "when user is a committee member" do
        let(:idea) { create(:idea, :created, organization: organization) }

        before do
          create(:ideas_committee_member, idea: idea, user: user)
        end

        it { is_expected.to be true }
      end

      context "when user is not an idea author" do
        let(:idea) { create(:idea, :created, organization: organization) }

        it { is_expected.to be false }
      end

      context "when user is admin" do
        let(:user) { create :user, :admin, organization: organization }
        let(:idea) { create(:idea, :created, author: user, organization: organization) }

        it { is_expected.to be true }
      end
    end

    context "when updating" do
      let(:action_name) { :update }
      let(:action) do
        { scope: :public, action: :edit, subject: :idea }
      end
      let(:context) do
        { idea: idea }
      end

      context "when idea is not created" do
        let(:idea) { create(:idea, organization: organization) }

        it { is_expected.to be false }
      end

      context "when user is a committee member" do
        let(:idea) { create(:idea, :created, organization: organization) }

        before do
          create(:ideas_committee_member, user: user, idea: idea)
        end

        it { is_expected.to be true }
      end

      context "when user is not an idea author" do
        let(:idea) { create(:idea, :created, organization: organization) }

        it { is_expected.to be false }
      end

      context "when user is admin" do
        let(:user) { create :user, :admin, organization: organization }
        let(:idea) { create(:idea, :created, author: user, organization: organization) }

        it { is_expected.to be true }
      end
    end
  end

  context "when requesting membership to an idea" do
    let(:action) do
      { scope: :public, action: :request_membership, subject: :idea }
    end
    let(:idea) { create(:idea, :discarded, organization: organization) }
    let(:context) do
      { idea: idea }
    end

    context "when idea is published" do
      let(:idea) { create(:idea, :published, organization: organization) }

      it { is_expected.to be false }
    end

    context "when idea is not published" do
      context "when user is member" do
        let(:idea) { create(:idea, :discarded, author: user, organization: organization) }

        it { is_expected.to be false }
      end

      context "when user is not a member" do
        let(:idea) { create(:idea, :discarded, organization: organization) }

        it { is_expected.to be false }

        context "when authorizations are not required" do
          before do
            allow(Decidim::Ideas)
              .to receive(:do_not_require_authorization)
              .and_return(true)
          end

          it { is_expected.to be true }
        end

        context "when user is authorized" do
          before do
            create :authorization, :granted, user: user
          end

          it { is_expected.to be true }
        end

        context "when user belongs to a verified user group" do
          before do
            create :user_group, :verified, users: [user], organization: user.organization
          end

          it { is_expected.to be true }
        end

        context "when user is not connected" do
          let(:user) { nil }

          it { is_expected.to be true }
        end
      end
    end
  end

  context "when voting an idea" do
    it_behaves_like "votes permissions" do
      let(:action) do
        { scope: :public, action: :vote, subject: :idea }
      end
    end
  end

  context "when signing an idea" do
    context "when idea signature has steps" do
      it_behaves_like "votes permissions" do
        let(:action) do
          { scope: :public, action: :sign_idea, subject: :idea }
        end
        let(:context) do
          { idea: idea, signature_has_steps: true }
        end
      end
    end

    context "when idea signature doesn't have steps" do
      let(:organization) { create(:organization, available_authorizations: authorizations) }
      let(:authorizations) { %w(dummy_authorization_handler another_dummy_authorization_handler) }
      let(:idea) { create(:idea, organization: organization) }
      let(:votes_enabled?) { true }
      let(:action) do
        { scope: :public, action: :sign_idea, subject: :idea }
      end
      let(:context) do
        { idea: idea, signature_has_steps: false }
      end

      before do
        allow(idea).to receive(:votes_enabled?).and_return(votes_enabled?)
      end

      context "when user has verified user groups" do
        before do
          create :user_group, :verified, users: [user], organization: user.organization
        end

        it { is_expected.to be false }
      end

      context "when the idea type has permissions to vote" do
        before do
          idea.type.create_resource_permission(
            permissions: {
              "vote" => {
                "authorization_handlers" => {
                  "dummy_authorization_handler" => { "options" => {} },
                  "another_dummy_authorization_handler" => { "options" => {} }
                }
              }
            }
          )
        end

        context "when user is fully verified" do
          before do
            create(:authorization, name: "dummy_authorization_handler", user: user, granted_at: 2.seconds.ago)
            create(:authorization, name: "another_dummy_authorization_handler", user: user, granted_at: 2.seconds.ago)
          end

          it { is_expected.to be false }
        end
      end
    end
  end

  context "when unvoting an idea" do
    let(:action) do
      { scope: :public, action: :unvote, subject: :idea }
    end
    let(:idea) { create(:idea, organization: organization) }
    let(:context) do
      { idea: idea }
    end
    let(:votes_enabled?) { true }
    let(:accepts_online_unvotes?) { true }

    before do
      allow(idea).to receive(:votes_enabled?).and_return(votes_enabled?)
      allow(idea).to receive(:accepts_online_unvotes?).and_return(accepts_online_unvotes?)
    end

    context "when idea has votes disabled" do
      let(:votes_enabled?) { false }

      it { is_expected.to be false }
    end

    context "when idea has unvotes disabled" do
      let(:accepts_online_unvotes?) { false }

      it { is_expected.to be false }
    end

    context "when user belongs to another organization" do
      let(:user) { create :user }

      it { is_expected.to be false }
    end

    context "when user has not voted the idea" do
      it { is_expected.to be false }
    end

    context "when user has verified user groups" do
      before do
        create :user_group, :verified, users: [user], organization: user.organization
        create(:idea_user_vote, idea: idea, author: user)
      end

      it { is_expected.to be true }
    end
  end
end
