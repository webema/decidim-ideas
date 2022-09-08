# frozen_string_literal: true

module Decidim
  module Ideas
    # A presenter to render statistics in the homepage.
    class IdeaStatsPresenter < SimpleDelegator
      def idea
        __getobj__.fetch(:idea)
      end

      def comments_count
        Rails.cache.fetch(
          "idea/#{idea.id}/comments_count",
          expires_in: Decidim::Ideas.stats_cache_expiration_time
        ) do
          idea.comments_count
        end
      end

      def meetings_count
        Rails.cache.fetch(
          "idea/#{idea.id}/meetings_count",
          expires_in: Decidim::Ideas.stats_cache_expiration_time
        ) do
          Decidim::Meetings::Meeting.where(component: meetings_component).count
        end
      end

      def assistants_count
        Rails.cache.fetch(
          "idea/#{idea.id}/assistants_count",
          expires_in: Decidim::Ideas.stats_cache_expiration_time
        ) do
          result = 0
          Decidim::Meetings::Meeting.where(component: meetings_component).each do |meeting|
            result += meeting.attendees_count || 0
          end

          result
        end
      end

      private

      def meetings_component
        @meetings_component ||= Decidim::Component.find_by(participatory_space: idea, manifest_name: "meetings")
      end
    end
  end
end
