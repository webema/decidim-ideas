# frozen_string_literal: true

module Decidim
  module Ideas
    # Helper method related to idea object and its internal state.
    module IdeaHelper
      include Decidim::SanitizeHelper
      include Decidim::ResourceVersionsHelper

      # Public: The css class applied based on the idea state to
      #         the idea badge.
      #
      # idea - Decidim::Idea
      #
      # Returns a String.
      def state_badge_css_class(idea)
        return "success" if idea.accepted?

        "warning"
      end

      # Public: The state of an idea in a way a human can understand.
      #
      # idea - Decidim::Idea.
      #
      # Returns a String.
      def humanize_state(idea)
        I18n.t(idea.accepted? ? "accepted" : "expired",
               scope: "decidim.ideas.states",
               default: :expired)
      end

      # Public: The state of an idea from an administration perspective in
      # a way that a human can understand.
      #
      # state - String
      #
      # Returns a String
      def humanize_admin_state(state)
        I18n.t(state, scope: "decidim.ideas.admin_states", default: :created)
      end

      def banner_image_path(idea)
        idea.attachments.find(&:image?)&.url || idea.type.attached_uploader(:banner_image)&.path
      end
    end
  end
end
