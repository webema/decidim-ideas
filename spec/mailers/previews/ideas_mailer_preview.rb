# frozen_string_literal: true

module Decidim
  module Ideas
    class IdeasMailerPreview < ActionMailer::Preview
      def notify_creation
        idea = Decidim::Idea.first
        Decidim::Ideas::IdeasMailer.notify_creation(idea)
      end

      def notify_progress
        idea = Decidim::Idea.first
        Decidim::Ideas::IdeasMailer.notify_progress(idea, idea.author)
      end

      def notify_state_change_to_published
        idea = Decidim::Idea.first
        idea.state = "published"
        Decidim::Ideas::IdeasMailer.notify_state_change(idea, idea.author)
      end

      def notify_state_change_to_discarded
        idea = Decidim::Idea.first
        idea.state = "discarded"
        Decidim::Ideas::IdeasMailer.notify_state_change(idea, idea.author)
      end

      def notify_state_change_to_accepted
        idea = Decidim::Idea.first
        idea.state = "accepted"
        Decidim::Ideas::IdeasMailer.notify_state_change(idea, idea.author)
      end

      def notify_state_change_to_rejected
        idea = Decidim::Idea.first
        idea.state = "rejected"
        Decidim::Ideas::IdeasMailer.notify_state_change(idea, idea.author)
      end
    end
  end
end
