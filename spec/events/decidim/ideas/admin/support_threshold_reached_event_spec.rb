# frozen_string_literal: true

require "spec_helper"

describe Decidim::Ideas::Admin::SupportThresholdReachedEvent do
  include_context "when a simple event"

  let(:event_name) { "decidim.events.ideas.support_threshold_reached" }
  let(:resource) { idea }

  let(:idea) { create :idea }
  let(:participatory_space) { idea }

  it_behaves_like "a simple event"

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
      expect(subject.email_subject).to eq("Signatures threshold reached")
    end
  end

  describe "email_intro" do
    it "is generated correctly" do
      expect(subject.email_intro)
        .to eq("The idea #{resource_title} has reached the signatures threshold")
    end
  end

  describe "email_outro" do
    it "is generated correctly" do
      expect(subject.email_outro)
        .to eq("You have received this notification because you are an admin of the platform.")
    end
  end

  describe "notification_title" do
    it "is generated correctly" do
      expect(subject.notification_title)
        .to include("The <a href=\"#{resource_path}\">#{resource_title}</a> idea has reached the signatures threshold")
    end
  end
end
