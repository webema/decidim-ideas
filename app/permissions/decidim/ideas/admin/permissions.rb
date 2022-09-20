# frozen_string_literal: true

module Decidim
  module Ideas
    module Admin
      class Permissions < Decidim::DefaultPermissions
        def permissions
          # The public part needs to be implemented yet
          return permission_action if permission_action.scope != :admin
          return permission_action unless user

          user_can_enter_space_area?

          return permission_action if idea && !idea.is_a?(Decidim::Idea)

          user_can_read_participatory_space?

          if !user.admin? && idea&.has_authorship?(user)
            idea_user_action?
            attachment_action?
            ideas_settings_action?

            return permission_action
          end

          if !user.admin? && has_ideas?
            read_idea_list_action?

            return permission_action
          end

          return permission_action unless user.admin?

          idea_type_action?
          idea_type_scope_action?
          idea_admin_user_action?
          idea_export_action?
          ideas_settings_action?
          moderator_action?
          allow! if permission_action.subject == :attachment

          permission_action
        end

        private

        def idea
          @idea ||= context.fetch(:idea, nil) || context.fetch(:current_participatory_space, nil)
        end

        def user_can_read_participatory_space?
          return unless permission_action.action == :read &&
                        permission_action.subject == :participatory_space

          toggle_allow(user.admin? || idea.has_authorship?(user))
        end

        def user_can_enter_space_area?
          return unless permission_action.action == :enter &&
                        permission_action.subject == :space_area &&
                        context.fetch(:space_name, nil) == :ideas

          toggle_allow(user.admin? || has_ideas?)
        end

        def has_ideas?
          (IdeasCreated.by(user)).any?
        end

        def attachment_action?
          return unless permission_action.subject == :attachment

          disallow! && return unless idea.attachments_enabled?

          attachment = context.fetch(:attachment, nil)
          attached = attachment&.attached_to

          case permission_action.action
          when :update, :destroy
            toggle_allow(attached && attached.is_a?(Decidim::Idea))
          when :read, :create
            allow!
          else
            disallow!
          end
        end

        def idea_type_action?
          return unless [:idea_type, :ideas_type].include? permission_action.subject

          idea_type = context.fetch(:idea_type, nil)

          case permission_action.action
          when :destroy
            scopes_are_empty = idea_type && idea_type.scopes.all? { |scope| scope.ideas.empty? }
            toggle_allow(scopes_are_empty)
          else
            allow!
          end
        end

        def idea_type_scope_action?
          return unless permission_action.subject == :idea_type_scope

          idea_type_scope = context.fetch(:idea_type_scope, nil)

          case permission_action.action
          when :destroy
            scopes_is_empty = idea_type_scope && idea_type_scope.ideas.empty?
            toggle_allow(scopes_is_empty)
          else
            allow!
          end
        end

        def idea_admin_user_action?
          return unless permission_action.subject == :idea

          case permission_action.action
          when :read
            toggle_allow(Decidim::Ideas.print_enabled)
          when :publish, :discard
            toggle_allow(idea.validating?)
          when :unpublish
            toggle_allow(idea.published?)
          when :accept
            # allowed = idea.published? &&
            #           idea.signature_end_date < Date.current &&
            #           idea.supports_goal_reached?
            toggle_allow(true)
          when :reject
            # allowed = idea.published? &&
            #           idea.signature_end_date < Date.current &&
            #           !idea.supports_goal_reached?
            toggle_allow(false)
          when :send_to_technical_validation
            toggle_allow(allowed_to_send_to_technical_validation?)
          else
            allow!
          end
        end

        def idea_export_action?
          allow! if permission_action.subject == :ideas && permission_action.action == :export
        end

        def ideas_settings_action?
          return unless permission_action.action == :update &&
                        permission_action.subject == :ideas_settings

          toggle_allow(user.admin?)
        end

        def moderator_action?
          return unless permission_action.subject == :moderation

          allow!
        end

        def read_idea_list_action?
          return unless permission_action.subject == :idea &&
                        permission_action.action == :list

          allow!
        end

        def idea_user_action?
          return unless permission_action.subject == :idea

          case permission_action.action
          when :read
            toggle_allow(Decidim::Ideas.print_enabled)
          when :preview, :edit
            allow!
          when :update
            toggle_allow(idea.created?)
          when :send_to_technical_validation
            toggle_allow(allowed_to_send_to_technical_validation?)
          else
            disallow!
          end
        end

        def allowed_to_send_to_technical_validation?
          idea.discarded? || idea.created?
        end
      end
    end
  end
end
