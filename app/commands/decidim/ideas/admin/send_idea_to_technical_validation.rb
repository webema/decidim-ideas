# frozen_string_literal: true

module Decidim
  module Ideas
    module Admin
      # A command with all the business logic that sends an
      # existing idea to technical validation.
      class SendIdeaToTechnicalValidation < Decidim::Command
        # Public: Initializes the command.
        #
        # idea - Decidim::Idea
        # current_user - the user performing the action
        def initialize(idea, current_user)
          @idea = idea
          @current_user = current_user
        end

        # Executes the command. Broadcasts these events:
        #
        # - :ok when everything is valid.
        # - :invalid if the form wasn't valid and we couldn't proceed.
        #
        # Returns nothing.
        def call
          @idea = Decidim.traceability.perform_action!(
            :send_to_technical_validation,
            idea,
            current_user
          ) do
            idea.validating!
            idea
          end

          notify_admins

          broadcast(:ok, idea)
        end

        private

        attr_reader :idea, :current_user

        def notify_admins
          affected_users = Decidim::User.org_admins_except_me(current_user).all

          data = {
            event: "decidim.events.ideas.admin.idea_sent_to_technical_validation",
            event_class: Decidim::Ideas::Admin::IdeaSentToTechnicalValidationEvent,
            resource: idea,
            affected_users: affected_users,
            force_send: true
          }

          Decidim::EventsManager.publish(**data)
        end
      end
    end
  end
end
