# frozen_string_literal: true

module Decidim
  module Ideas
    # This cell renders the Medium (:m) idea card
    # for an given instance of an Idea
    class IdeaMCell < Decidim::CardMCell
      include Decidim::Ideas::Engine.routes.url_helpers
      include Decidim::TwitterSearchHelper

      property :state

      private

      def title
        decidim_html_escape(translated_attribute(model.title))
      end

      def hashtag
        decidim_html_escape(model.hashtag)
      end

      def has_state?
        true
      end

      # Explicitely commenting the used I18n keys so their are not flagged as unused
      # i18n-tasks-use t('decidim.ideas.show.badge_name.accepted')
      # i18n-tasks-use t('decidim.ideas.show.badge_name.created')
      # i18n-tasks-use t('decidim.ideas.show.badge_name.discarded')
      # i18n-tasks-use t('decidim.ideas.show.badge_name.published')
      # i18n-tasks-use t('decidim.ideas.show.badge_name.rejected')
      # i18n-tasks-use t('decidim.ideas.show.badge_name.validating')
      def badge_name
        I18n.t(model.state, scope: "decidim.ideas.show.badge_name")
      end

      def state_classes
        case state
        when "accepted", "published"
          ["success"]
        when "rejected", "discarded"
          ["alert"]
        when "validating"
          ["warning"]
        else
          ["muted"]
        end
      end

      def resource_path
        idea_path(model)
      end

      def resource_icon
        icon "ideas", class: "icon--big"
      end

      def authors
        [present(model).author]
      end

      def has_image?
        image.present?
      end

      def image
        @image ||= model.attachments.find(&:image?)
      end

      def resource_image_path
        image.url if has_image?
      end

      def likes_status
        cell "decidim/likes_button", model, inline: true, card_m: true
      end

      def statuses
        [:likes, :follow, :comments_count]
      end

      # def comments_count_status
      #   'TODO'
      # end

      # def creation_date_status
      #   'TODO'
      # end
    end
  end
end
