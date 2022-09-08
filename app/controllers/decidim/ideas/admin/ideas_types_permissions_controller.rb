# frozen_string_literal: true

module Decidim
  module Ideas
    module Admin
      # Controller that allows managing ideas types
      # permissions in the admin panel.
      class IdeasTypesPermissionsController < Decidim::Admin::ResourcePermissionsController
        layout "decidim/admin/ideas"

        register_permissions(::Decidim::Ideas::Admin::IdeasTypesPermissionsController,
                             ::Decidim::Ideas::Permissions,
                             ::Decidim::Admin::Permissions)

        def permission_class_chain
          ::Decidim.permissions_registry.chain_for(::Decidim::Ideas::Admin::IdeasTypesPermissionsController)
        end
      end
    end
  end
end
