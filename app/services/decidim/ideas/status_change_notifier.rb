# frozen_string_literal: true

module Decidim
  module Ideas
    # Service that reports changes in idea status
    class StatusChangeNotifier
      attr_reader :idea

      def initialize(args = {})
        @idea = args.fetch(:idea)
      end

      # PUBLIC
      # Notifies when an idea has changed its status.
      #
      # * created: Notifies the author that their idea has been created.
      #
      # * validating: Administrators will be notified about the idea that
      #   requests technical validation.
      #
      # * published, discarded: Idea authors will be notified about the
      #   result of the technical validation process.
      #
      # * rejected, accepted: Idea's followers and authors will be
      #   notified about the result of the idea.
      def notify
        notify_idea_creation if idea.created?
        notify_validating_idea if idea.validating?
        notify_validating_result if idea.published? || idea.discarded?
        notify_support_result if idea.rejected? || idea.accepted?
      end

      private

      def notify_idea_creation
        Decidim::Ideas::IdeasMailer
          .notify_creation(idea)
          .deliver_later
      end

      # Does nothing
      def notify_validating_idea
        # It has been moved into SendIdeaToTechnicalValidation command as a standard notification
        # It would be great to move the functionality of this class, which is invoked on Idea#after_save,
        # to the corresponding commands to follow the architecture of Decidim.
      end

      def notify_validating_result
        # idea.committee_members.approved.each do |committee_member|
        #   Decidim::Ideas::IdeasMailer
        #     .notify_state_change(idea, committee_member.user)
        #     .deliver_later
        # end

        Decidim::Ideas::IdeasMailer
          .notify_state_change(idea, idea.author)
          .deliver_later
      end

      def notify_support_result
        idea.followers.each do |follower|
          Decidim::Ideas::IdeasMailer
            .notify_state_change(idea, follower)
            .deliver_later
        end

        # idea.committee_members.approved.each do |committee_member|
        #   Decidim::Ideas::IdeasMailer
        #     .notify_state_change(idea, committee_member.user)
        #     .deliver_later
        # end

        Decidim::Ideas::IdeasMailer
          .notify_state_change(idea, idea.author)
          .deliver_later
      end
    end
  end
end
