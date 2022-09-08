# frozen_string_literal: true

module Decidim
  module Ideas
    module Admin
      # Controller that allows managing the Idea's Components in the
      # admin panel.
      class ComponentsController < Decidim::Admin::ComponentsController
        layout "decidim/admin/idea"

        include NeedsIdea
      end
    end
  end
end
