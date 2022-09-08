# frozen_string_literal: true

module Decidim
  module Ideas
    class Permissions < Decidim::DefaultPermissions
      def permissions
        # Delegate the admin permission checks to the admin permissions class
        return Decidim::Ideas::Admin::Permissions.new(user, permission_action, context).permissions if permission_action.scope == :admin
        return permission_action if permission_action.scope != :public

        # Non-logged users permissions
        list_public_ideas?
        read_public_idea?
        search_idea_types_and_scopes?
        request_membership?

        return permission_action unless user

        create_idea?
        edit_public_idea?
        update_public_idea?

        # vote_idea?
        # sign_idea?
        # unvote_idea?

        idea_attachment?

        # idea_committee_action?
        send_to_technical_validation?

        permission_action
      end

      private

      def idea
        @idea ||= context.fetch(:idea, nil) || context.fetch(:current_participatory_space, nil)
      end

      def idea_type
        @idea_type ||= context[:idea_type]
      end

      def list_public_ideas?
        allow! if permission_action.subject == :idea &&
                  permission_action.action == :list
      end

      def read_public_idea?
        return unless [:idea, :participatory_space].include?(permission_action.subject) &&
                      permission_action.action == :read

        return allow! if idea.published? || idea.rejected? || idea.accepted?
        return allow! if user && authorship_or_admin?

        disallow!
      end

      def search_idea_types_and_scopes?
        return unless permission_action.action == :search
        return unless [:idea_type, :idea_type_scope].include?(permission_action.subject)

        allow!
      end

      def create_idea?
        return unless permission_action.subject == :idea &&
                      permission_action.action == :create

        toggle_allow(creation_enabled?)
      end

      def edit_public_idea?
        return unless permission_action.subject == :idea &&
                      permission_action.action == :edit

        toggle_allow(idea&.created? && authorship_or_admin?)
      end

      def update_public_idea?
        return unless permission_action.subject == :idea &&
                      permission_action.action == :update

        toggle_allow(idea&.created? && authorship_or_admin?)
      end

      def creation_enabled?
        Decidim::Ideas.creation_enabled && (
        Decidim::Ideas.do_not_require_authorization ||
            UserAuthorizations.for(user).any? ||
            Decidim::UserGroups::ManageableUserGroups.for(user).verified.any?
      )
      end

      def request_membership?
        return unless permission_action.subject == :idea &&
                      permission_action.action == :request_membership

        toggle_allow(can_request_membership?)
      end

      def can_request_membership?
        return access_request_without_user? if user.blank?

        access_request_membership?
      end

      def access_request_without_user?
        Decidim::Ideas.do_not_require_authorization # (!idea.published? && idea.promoting_committee_enabled?) || 
      end

      # def access_request_membership?
      #   !idea.published? &&
      #     idea.promoting_committee_enabled? &&
      #     !idea.has_authorship?(user) &&
      #     (
      #     Decidim::Ideas.do_not_require_authorization ||
      #         UserAuthorizations.for(user).any? ||
      #         Decidim::UserGroups::ManageableUserGroups.for(user).verified.any?
      #   )
      # end

      # def vote_idea?
      #   return unless permission_action.action == :vote &&
      #                 permission_action.subject == :idea

      #   toggle_allow(can_vote?)
      # end

      def authorized?(permission_action, resource: nil, permissions_holder: nil)
        return unless resource || permissions_holder

        ActionAuthorizer.new(user, permission_action, permissions_holder, resource).authorize.ok?
      end

      # def unvote_idea?
      #   return unless permission_action.action == :unvote &&
      #                 permission_action.subject == :idea

      #   can_unvote = idea.accepts_online_unvotes? &&
      #                idea.organization&.id == user.organization&.id &&
      #                idea.votes.where(author: user).any? &&
      #                authorized?(:vote, resource: idea, permissions_holder: idea.type)

      #   toggle_allow(can_unvote)
      # end

      def idea_attachment?
        return unless permission_action.action == :add_attachment &&
                      permission_action.subject == :idea

        toggle_allow(idea_type.attachments_enabled?)
      end

      # def sign_idea?
      #   return unless permission_action.action == :sign_idea &&
      #                 permission_action.subject == :idea

      #   can_sign = can_vote? &&
      #              context.fetch(:signature_has_steps, false)

      #   toggle_allow(can_sign)
      # end

      def decidim_user_group_id
        context.fetch(:group_id, nil)
      end

      # def can_vote?
      #   idea.votes_enabled? &&
      #     idea.organization&.id == user.organization&.id &&
      #     idea.votes.where(author: user).empty? &&
      #     authorized?(:vote, resource: idea, permissions_holder: idea.type)
      # end

      # def can_user_support?(idea)
      #   !idea.offline_signature_type? && (
      #   Decidim::Ideas.do_not_require_authorization ||
      #       UserAuthorizations.for(user).any?
      # )
      # end

      # def idea_committee_action?
      #   return unless permission_action.subject == :idea_committee_member

      #   request = context.fetch(:request, nil)
      #   return unless user.admin? || idea&.has_authorship?(user)

      #   case permission_action.action
      #   when :index
      #     allow!
      #   when :approve
      #     toggle_allow(!request&.accepted?)
      #   when :revoke
      #     toggle_allow(!request&.rejected?)
      #   end
      # end

      def send_to_technical_validation?
        return unless permission_action.action == :send_to_technical_validation &&
                      permission_action.subject == :idea

        toggle_allow(allowed_to_send_to_technical_validation?)
      end

      def allowed_to_send_to_technical_validation?
        idea.created? #&&  (!idea.created_by_individual? || idea.enough_committee_members?)
      end

      def authorship_or_admin?
        idea&.has_authorship?(user) || user.admin?
      end
    end
  end
end
