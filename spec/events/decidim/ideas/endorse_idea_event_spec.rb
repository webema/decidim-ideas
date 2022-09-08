# frozen_string_literal: true

require "spec_helper"

describe Decidim::Ideas::EndorseIdeaEvent do
  subject do
    described_class.new(resource: idea, event_name: event_name, user: user, extra: {})
  end

  let(:organization) { idea.organization }
  let(:idea) { create :idea }
  let(:idea_author) { idea.author }
  let(:event_name) { "decidim.events.ideas.idea_endorsed" }
  let(:user) { create :user, organization: organization }
  let(:resource_path) { resource_locator(idea).path }

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
      expect(subject.email_subject).to eq("Idea endorsed by @#{idea_author.nickname}")
    end
  end

  describe "email_intro" do
    it "is generated correctly" do
      expect(subject.email_intro).to eq("#{idea_author.name} @#{idea_author.nickname}, who you are following, has endorsed the following idea, maybe you want to contribute to the conversation:")
    end
  end

  describe "email_outro" do
    it "is generated correctly" do
      expect(subject.email_outro)
        .to eq("You have received this notification because you are following @#{idea_author.nickname}. You can stop receiving notifications following the previous link.")
    end
  end

  describe "notification_title" do
    it "is generated correctly" do
      expect(subject.notification_title)
        .to include("The <a href=\"#{resource_path}\">#{idea.title["en"]}</a> idea was endorsed by ")

      expect(subject.notification_title)
        .to include("<a href=\"/profiles/#{idea_author.nickname}\">#{idea_author.name} @#{idea_author.nickname}</a>.")
    end
  end
end
