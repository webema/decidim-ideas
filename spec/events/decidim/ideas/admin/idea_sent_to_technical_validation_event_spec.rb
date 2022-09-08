# frozen_string_literal: true

require "spec_helper"

describe Decidim::Ideas::Admin::IdeaSentToTechnicalValidationEvent do
  let(:resource) { create :idea }
  let(:event_name) { "decidim.events.ideas.admin.idea_sent_to_technical_validation" }
  let(:admin_idea_path) { "/admin/ideas/#{resource.slug}/edit?idea_slug=#{resource.slug}" }
  let(:admin_idea_url) { "http://#{organization.host}#{admin_idea_path}" }

  include_context "when a simple event"
  it_behaves_like "a simple event"

  describe "email_subject" do
    it "is generated correctly" do
      expect(subject.email_subject).to eq("Idea \"#{resource_title}\" was sent to technical validation.")
    end
  end

  describe "email_intro" do
    it "is generated correctly" do
      expect(subject.email_intro)
        .to eq(%(The idea "#{resource_title}" has been sent to technical validation. Check it out at <a href="#{admin_idea_url}">the admin panel</a>))
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
        .to include(%(The idea "#{resource_title}" has been sent to technical validation. Check it out at <a href="#{admin_idea_path}">the admin panel</a>))
    end
  end
end
