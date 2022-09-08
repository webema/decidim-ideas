# frozen_string_literal: true

module Decidim
  module Ideas
    # Service that notifies progress for an idea
    class ProgressNotifier
      attr_reader :idea

      def initialize(args = {})
        @idea = args.fetch(:idea)
      end

      # PUBLIC: Notifies the support progress of the idea.
      #
      # Notifies to Idea's authors and followers about the
      # number of supports received by the idea.
      def notify
        idea.followers.each do |follower|
          Decidim::Ideas::IdeasMailer
            .notify_progress(idea, follower)
            .deliver_later
        end

        # idea.committee_members.approved.each do |committee_member|
        #   Decidim::Ideas::IdeasMailer
        #     .notify_progress(idea, committee_member.user)
        #     .deliver_later
        # end

        Decidim::Ideas::IdeasMailer
          .notify_progress(idea, idea.author)
          .deliver_later
      end
    end
  end
end
