# frozen_string_literal: true

require "spec_helper"

describe Decidim::Ideas::SpawnCommitteeRequestEvent do
  subject do
    described_class.new(
      resource: idea,
      event_name: event_name,
      user: [idea.author],
      user_role: :affected_user,
      extra: { applicant: applicant }
    )
  end

  let(:organization) { idea.organization }
  let(:idea) { create :idea }
  let(:event_name) { "decidim.events.ideas.idea_created" }
  let(:applicant) { create :user, organization: organization }
  let(:applicant_profile_url) { Decidim::UserPresenter.new(applicant).profile_url }
  let(:applicant_nickname) { Decidim::UserPresenter.new(applicant).nickname }
  let(:resource_url) { resource_locator(idea).url }
  let(:resource_title) { translated(idea.title) }

  describe "types" do
    subject { described_class }

    it "supports notifications" do
      expect(subject.types).to include :notification
    end

    it "supports emails" do
      expect(subject.types).to include :email
    end
  end

  describe "email_subject" do
    it "is generated correctly" do
      expect(subject.email_subject).to eq("#{applicant_nickname} wants to join your idea")
    end
  end

  describe "email_intro" do
    it "is generated correctly" do
      expect(subject.email_intro).to eq("#{applicant_nickname} applied for the promoter committee of your idea #{resource_title}. To accept or reject the application, go to the edit form of your idea.")
    end
  end

  describe "email_outro" do
    it "is generated correctly" do
      expect(subject.email_outro)
        .to eq("You received this notification because you are the author of this idea: #{resource_title}")
    end
  end

  describe "notification_title" do
    it "is generated correctly" do
      expect(subject.notification_title)
        .to eq("<a href=\"#{applicant_profile_url}\">#{applicant_nickname}</a> applied for the promoter committee of your idea <a href=\"#{resource_url}\">#{resource_title}</a>. To accept or reject click <a href=\"#{resource_url}/edit\">here</a>.")
    end
  end
end
