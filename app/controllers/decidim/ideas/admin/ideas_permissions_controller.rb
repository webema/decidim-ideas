# frozen_string_literal: true

module Decidim
  module Ideas
    module Admin
      # Controller that allows managing ideas
      # permissions in the admin panel.
      class IdeasPermissionsController < Decidim::Admin::ResourcePermissionsController
        include Decidim::Ideas::NeedsIdea

        layout "decidim/admin/ideas"

        register_permissions(::Decidim::Ideas::Admin::IdeasPermissionsController,
                             ::Decidim::Ideas::Permissions,
                             ::Decidim::Admin::Permissions)

        def resource
          current_idea
        end

        def permission_class_chain
          ::Decidim.permissions_registry.chain_for(::Decidim::Ideas::Admin::IdeasPermissionsController)
        end
      end
    end
  end
end
