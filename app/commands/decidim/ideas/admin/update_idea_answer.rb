# frozen_string_literal: true

module Decidim
  module Ideas
    module Admin
      # A command with all the business logic to answer
      # ideas.
      class UpdateIdeaAnswer < Decidim::Command
        # Public: Initializes the command.
        #
        # idea   - Decidim::Idea
        # form         - A form object with the params.
        # current_user - Decidim::User
        def initialize(idea, form, current_user)
          @form = form
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
          return broadcast(:invalid) if form.invalid?

          @idea = Decidim.traceability.update!(
            idea,
            current_user,
            attributes
          )
          notify_idea_is_extended if @notify_extended
          broadcast(:ok, idea)
        rescue ActiveRecord::RecordInvalid
          broadcast(:invalid, idea)
        end

        private

        attr_reader :form, :idea, :current_user

        def attributes
          attrs = {
            answer: form.answer,
            answer_url: form.answer_url
          }

          attrs[:answered_at] = Time.current if form.answer.present?

          # if form.signature_dates_required?
          #   attrs[:signature_start_date] = form.signature_start_date
          #   attrs[:signature_end_date] = form.signature_end_date

          #   if idea.published? && form.signature_end_date != idea.signature_end_date &&
          #      form.signature_end_date > idea.signature_end_date
          #     @notify_extended = true
          #   end
          # end

          attrs
        end

        def notify_idea_is_extended
          Decidim::EventsManager.publish(
            event: "decidim.events.ideas.idea_extended",
            event_class: Decidim::Ideas::ExtendIdeaEvent,
            resource: idea,
            followers: idea.followers - [idea.author]
          )
        end
      end
    end
  end
end
