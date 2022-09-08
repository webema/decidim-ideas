# frozen_string_literal: true

require "spec_helper"

describe "decidim_ideas:notify_progress", type: :task do
  it "preloads the Rails environment" do
    expect(task.prerequisites).to include "environment"
  end

  it "runs gracefully" do
    expect { task.execute }.not_to raise_error
  end

  context "when idea without supports" do
    let(:idea) { create(:idea) }

    it "Keeps idea unchanged" do
      expect(idea.online_votes_count).to be_zero

      task.execute
      expect(idea.first_progress_notification_at).to be_nil
      expect(idea.second_progress_notification_at).to be_nil
    end

    it "do not invokes the mailer" do
      expect(Decidim::Ideas::IdeasMailer).not_to receive(:notify_progress)
      task.execute
    end
  end

  context "when idea ready for first notification" do
    let(:idea) do
      idea = create(:idea)

      votes_needed = (idea.supports_required * (Decidim::Ideas.first_notification_percentage / 100.0)) + 1
      idea.online_votes["total"] = votes_needed
      idea.save!

      idea
    end

    let(:message_delivery) { instance_double(ActionMailer::MessageDelivery) }

    before do
      allow(message_delivery).to receive(:deliver_later)
    end

    it "updates notification time" do
      expect(idea.percentage).to be >= Decidim::Ideas.first_notification_percentage
      expect(idea.percentage).to be < Decidim::Ideas.second_notification_percentage

      task.execute

      idea.reload
      expect(idea.first_progress_notification_at).not_to be_nil
      expect(idea.second_progress_notification_at).to be_nil
    end

    it "invokes the mailer" do
      expect(idea.percentage).to be >= Decidim::Ideas.first_notification_percentage
      expect(idea.percentage).to be < Decidim::Ideas.second_notification_percentage

      expect(Decidim::Ideas::IdeasMailer).to receive(:notify_progress)
        .at_least(:once)
        .and_return(message_delivery)
      task.execute
    end
  end

  context "when idea ready for second notification" do
    let(:idea) do
      idea = create(:idea, first_progress_notification_at: Time.current)

      votes_needed = (idea.supports_required * (Decidim::Ideas.second_notification_percentage / 100.0)) + 1

      idea.online_votes["total"] = votes_needed
      idea.save!

      idea
    end

    let(:message_delivery) { instance_double(ActionMailer::MessageDelivery) }

    before do
      allow(message_delivery).to receive(:deliver_later)
    end

    it "updates notification time" do
      expect(idea.percentage).to be >= Decidim::Ideas.second_notification_percentage

      task.execute

      idea.reload
      expect(idea.second_progress_notification_at).not_to be_nil
    end

    it "invokes the mailer" do
      expect(idea.percentage).to be >= Decidim::Ideas.second_notification_percentage
      expect(Decidim::Ideas::IdeasMailer).to receive(:notify_progress)
        .at_least(:once)
        .and_return(message_delivery)
      task.execute
    end
  end

  context "when idea with both notifications sent" do
    let(:idea) do
      create(:idea,
             first_progress_notification_at: Time.current,
             second_progress_notification_at: Time.current)
    end

    it "do not invokes the mailer" do
      expect(Decidim::Ideas::IdeasMailer).not_to receive(:notify_progress)
      task.execute
    end
  end
end
