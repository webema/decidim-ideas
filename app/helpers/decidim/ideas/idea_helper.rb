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

      # def popularity_tag(idea)
      #   content_tag(:div, class: "extra__popularity popularity #{popularity_class(idea)}".strip) do
      #     5.times do
      #       concat(content_tag(:span, class: "popularity__item") do
      #         # empty block
      #       end)
      #     end

      #     concat(content_tag(:span, class: "popularity__desc") do
      #       I18n.t("decidim.ideas.ideas.vote_cabin.supports_required",
      #              total_supports: idea.scoped_type.supports_required)
      #     end)
      #   end
      # end

      def popularity_class(idea)
        return "popularity--level1" if popularity_level1?(idea)
        return "popularity--level2" if popularity_level2?(idea)
        return "popularity--level3" if popularity_level3?(idea)
        return "popularity--level4" if popularity_level4?(idea)
        return "popularity--level5" if popularity_level5?(idea)

        ""
      end

      def popularity_level1?(idea)
        idea.percentage.positive? && idea.percentage < 40
      end

      def popularity_level2?(idea)
        idea.percentage >= 40 && idea.percentage < 60
      end

      def popularity_level3?(idea)
        idea.percentage >= 60 && idea.percentage < 80
      end

      def popularity_level4?(idea)
        idea.percentage >= 80 && idea.percentage < 100
      end

      def popularity_level5?(idea)
        idea.percentage >= 100
      end

      def authorized_vote_modal_button(idea, html_options, &block)
        return if current_user && action_authorized_to("vote", resource: idea, permissions_holder: idea.type).ok?

        tag = "button"
        html_options ||= {}

        if current_user
          html_options["data-open"] = "authorizationModal"
          html_options["data-open-url"] = authorization_sign_modal_idea_path(idea)
        else
          html_options["data-open"] = "loginModal"
        end

        html_options["onclick"] = "event.preventDefault();"

        send("#{tag}_to", "", html_options, &block)
      end

      def can_edit_custom_signature_end_date?(idea)
        return false unless idea.custom_signature_end_date_enabled?

        idea.created? || idea.validating?
      end

      def can_edit_area?(idea)
        # return false unless idea.area_enabled?

        # idea.created? || idea.validating?
        false
      end
    end
  end
end
