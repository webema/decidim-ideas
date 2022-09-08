# frozen_string_literal: true

module Decidim
  module Ideas
    module AdminLog
      # This class holds the logic to present a `Decidim::IdeasSettings`
      # for the `AdminLog` log.
      #
      # Usage should be automatic and you shouldn't need to call this class
      # directly, but here's an example:
      #
      #    action_log = Decidim::ActionLog.last
      #    view_helpers # => this comes from the views
      #    IdeasSettingsPresenter.new(action_log, view_helpers).present
      class IdeasSettingsPresenter < Decidim::Log::BasePresenter
        private

        def action_string
          case action
          when "update"
            "decidim.ideas.admin_log.ideas_settings.#{action}"
          end
        end
      end
    end
  end
end
