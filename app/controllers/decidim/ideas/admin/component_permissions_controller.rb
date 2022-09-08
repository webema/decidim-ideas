# frozen_string_literal: true

module Decidim
  module Ideas
    module Admin
      # Controller that allows managing the Idea's Component
      # permissions in the admin panel.
      class ComponentPermissionsController < Decidim::Admin::ComponentPermissionsController
        include IdeaAdmin
      end
    end
  end
end
