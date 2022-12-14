# frozen_string_literal: true

module Decidim
  module Ideas
    module Admin
      module Moderations
        # This controller allows admins to manage moderation reports in an conference.
        class ReportsController < Decidim::Admin::Moderations::ReportsController
          include IdeaAdmin

          def permissions_context
            super.merge(current_participatory_space: current_participatory_space)
          end
        end
      end
    end
  end
end
