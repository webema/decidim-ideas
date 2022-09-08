# frozen_string_literal: true

module Decidim
  module Ideas
    module Admin
      # This controller allows admins to manage moderations in an conference.
      class ModerationsController < Decidim::Admin::ModerationsController
        include IdeaAdmin

        def permissions_context
          super.merge(current_participatory_space: current_participatory_space)
        end
      end
    end
  end
end
