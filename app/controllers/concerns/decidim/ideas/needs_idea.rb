# frozen_string_literal: true

require "active_support/concern"

module Decidim
  module Ideas
    # This module, when injected into a controller, ensures there's an
    # idea available and deducts it from the context.
    module NeedsIdea
      extend ActiveSupport::Concern

      RegistersPermissions
        .register_permissions("#{::Decidim::Ideas::NeedsIdea.name}/admin",
                              Decidim::Ideas::Permissions,
                              Decidim::Admin::Permissions)
      RegistersPermissions
        .register_permissions("#{::Decidim::Ideas::NeedsIdea.name}/public",
                              Decidim::Ideas::Permissions,
                              Decidim::Admin::Permissions,
                              Decidim::Permissions)

      included do
        include NeedsOrganization
        include IdeaSlug

        helper_method :current_idea, :current_participatory_space, :signature_has_steps?

        # Public: Finds the current Idea given this controller's
        # context.
        #
        # Returns the current Idea.
        def current_idea
          @current_idea ||= detect_idea
        end

        alias_method :current_participatory_space, :current_idea

        # Public: Wether the current idea belongs to an idea type
        # which requires one or more step before creating a signature
        #
        # Returns nil if there is no current_idea, true or false
        # def signature_has_steps?
        #   return unless current_idea

        #   idea_type = current_idea.scoped_type.type
        #   idea_type.collect_user_extra_fields? || idea_type.validate_sms_code_on_votes?
        # end

        private

        def detect_idea
          request.env["current_idea"] ||
            Idea.find_by(
              id: (id_from_slug(params[:slug]) || id_from_slug(params[:idea_slug]) || params[:idea_id] || params[:id]),
              organization: current_organization
            )
        end

        def permission_class_chain
          if permission_scope == :admin
            PermissionsRegistry.chain_for("#{::Decidim::Ideas::NeedsIdea.name}/admin")
          else
            PermissionsRegistry.chain_for("#{::Decidim::Ideas::NeedsIdea.name}/public")
          end
        end
      end
    end
  end
end
