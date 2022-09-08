# frozen_string_literal: true

module Decidim
  module Ideas
    module AdminLog
      # This class holds the logic to present a `Decidim::IdeasType`
      # for the `AdminLog` log.
      #
      # Usage should be automatic and you shouldn't need to call this class
      # directly, but here's an example:
      #
      #    action_log = Decidim::ActionLog.last
      #    view_helpers # => this comes from the views
      #    IdeasTypePresenter.new(action_log, view_helpers).present
      class IdeasTypePresenter < Decidim::Log::BasePresenter
        private

        def action_string
          case action
          when "create", "update", "delete"
            "decidim.ideas.admin_log.ideas_type.#{action}"
          else
            super
          end
        end

        def diff_fields_mapping
          {
            description: :i18n,
            title: :i18n
          }
        end

        def diff_actions
          super + %w(update)
        end
      end
    end
  end
end
