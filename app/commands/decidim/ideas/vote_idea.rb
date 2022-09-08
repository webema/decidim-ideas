# frozen_string_literal: true

module Decidim
  module Ideas
    # A command with all the business logic when a user or organization votes an idea.
    class VoteIdea < Decidim::Command
      # Public: Initializes the command.
      #
      # form - A form object with the params.
      def initialize(form)
        @form = form
      end

      # Executes the command. Broadcasts these events:
      #
      # - :ok when everything is valid, together with the proposal vote.
      # - :invalid if the form wasn't valid and we couldn't proceed.
      #
      # Returns nothing.
      def call
        return broadcast(:invalid) if form.invalid?

        percentage_before = idea.percentage

        Idea.transaction do
          create_votes
        end

        percentage_after = idea.reload.percentage

        send_notification
        notify_percentage_change(percentage_before, percentage_after)
        notify_support_threshold_reached(percentage_before, percentage_after)

        broadcast(:ok, votes)
      end

      attr_reader :votes

      private

      attr_reader :form

      delegate :idea, to: :form

      def create_votes
        @votes = form.authorized_scopes.map do |scope|
          idea.votes.create!(
            author: form.signer,
            encrypted_metadata: form.encrypted_metadata,
            timestamp: timestamp,
            hash_id: form.hash_id,
            scope: scope
          )
        end
      end

      def timestamp
        return unless timestamp_service

        @timestamp ||= timestamp_service.new(document: form.encrypted_metadata).timestamp
      end

      def timestamp_service
        @timestamp_service ||= Decidim.timestamp_service.to_s.safe_constantize
      end

      def send_notification
        Decidim::EventsManager.publish(
          event: "decidim.events.ideas.idea_endorsed",
          event_class: Decidim::Ideas::EndorseIdeaEvent,
          resource: idea,
          followers: idea.author.followers
        )
      end

      def notify_percentage_change(before, after)
        percentage = [25, 50, 75, 100].find do |milestone|
          before < milestone && after >= milestone
        end

        return unless percentage

        Decidim::EventsManager.publish(
          event: "decidim.events.ideas.milestone_completed",
          event_class: Decidim::Ideas::MilestoneCompletedEvent,
          resource: idea,
          affected_users: [idea.author],
          followers: idea.followers - [idea.author],
          extra: {
            percentage: percentage
          }
        )
      end

      def notify_support_threshold_reached(before, after)
        # Don't need to notify if threshold has already been reached
        return if before == after || after != 100

        Decidim::EventsManager.publish(
          event: "decidim.events.ideas.support_threshold_reached",
          event_class: Decidim::Ideas::Admin::SupportThresholdReachedEvent,
          resource: idea,
          followers: idea.organization.admins
        )
      end
    end
  end
end
