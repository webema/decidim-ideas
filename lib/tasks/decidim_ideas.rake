# frozen_string_literal: true

namespace :decidim_ideas do
  desc "Check validating ideas and moves all without changes for a configured time to discarded state"
  task check_validating: :environment do
    Decidim::Ideas::OutdatedValidatingIdeas
      .for(Decidim::Ideas.max_time_in_validating_state)
      .each(&:discarded!)
  end

  desc "Check published ideas and moves to accepted/rejected state depending on the votes collected when the signing period has finished"
  task check_published: :environment do
    Decidim::Ideas::SupportPeriodFinishedIdeas.new.each do |idea|
      if idea.supports_goal_reached?
        idea.accepted!
      else
        idea.rejected!
      end
    end
  end

  desc "Notify progress on published ideas"
  task notify_progress: :environment do
    Decidim::Idea
      .published
      .where.not(first_progress_notification_at: nil)
      .where(second_progress_notification_at: nil).find_each do |idea|
      if idea.percentage >= Decidim::Ideas.second_notification_percentage
        notifier = Decidim::Ideas::ProgressNotifier.new(idea: idea)
        notifier.notify

        idea.second_progress_notification_at = Time.now.utc
        idea.save
      end
    end

    Decidim::Idea
      .published
      .where(first_progress_notification_at: nil).find_each do |idea|
      if idea.percentage >= Decidim::Ideas.first_notification_percentage
        notifier = Decidim::Ideas::ProgressNotifier.new(idea: idea)
        notifier.notify

        idea.first_progress_notification_at = Time.now.utc
        idea.save
      end
    end
  end
end
