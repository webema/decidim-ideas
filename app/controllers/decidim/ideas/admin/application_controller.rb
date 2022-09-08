# frozen_string_literal: true

module Decidim
  module Ideas
    module Admin
      # The main admin application controller for ideas
      class ApplicationController < Decidim::Admin::ApplicationController
        layout "decidim/admin/ideas"

        register_permissions(::Decidim::Ideas::Admin::ApplicationController,
                             ::Decidim::Ideas::Permissions,
                             ::Decidim::Admin::Permissions)

        def permissions_context
          super.merge(
            current_participatory_space: try(:current_participatory_space)
          )
        end

        def permission_class_chain
          ::Decidim.permissions_registry.chain_for(::Decidim::Ideas::Admin::ApplicationController)
        end
      end
    end
  end
end
