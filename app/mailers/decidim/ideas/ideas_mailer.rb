# frozen_string_literal: true

module Decidim
  module Ideas
    # Mailer for ideas engine.
    class IdeasMailer < Decidim::ApplicationMailer
      include Decidim::TranslatableAttributes
      include Decidim::SanitizeHelper

      helper Decidim::TranslatableAttributes
      helper Decidim::SanitizeHelper

      # Notifies idea creation
      def notify_creation(idea)
        return if idea.author.email.blank?

        @idea = idea
        @organization = idea.organization

        with_user(idea.author) do
          @subject = I18n.t(
            "decidim.ideas.ideas_mailer.creation_subject",
            title: translated_attribute(idea.title)
          )

          mail(to: "#{idea.author.name} <#{idea.author.email}>", subject: @subject)
        end
      end

      # Notify changes in state
      def notify_state_change(idea, user)
        return if user.email.blank?

        @organization = idea.organization
        @idea = idea

        with_user(user) do
          @subject = I18n.t("decidim.ideas.ideas_mailer.#{idea.state}_subject")

          @body = I18n.t(
            "decidim.ideas.ideas_mailer.status_change_body_for",
            title: translated_attribute(idea.title),
            state: I18n.t(idea.state, scope: "decidim.ideas.admin_states")
          )

          @link = idea_url(idea, host: @organization.host)

          mail(to: "#{user.name} <#{user.email}>", subject: @subject)
        end
      end
    end
  end
end
