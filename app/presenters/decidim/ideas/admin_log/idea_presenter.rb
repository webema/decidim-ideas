# frozen_string_literal: true

module Decidim
  module Ideas
    module AdminLog
      # This class holds the logic to present a `Decidim::Idea`
      # for the `AdminLog` log.
      #
      # Usage should be automatic and you shouldn't need to call this class
      # directly, but here's an example:
      #
      #    action_log = Decidim::ActionLog.last
      #    view_helpers # => this comes from the views
      #    IdeaPresenter.new(action_log, view_helpers).present
      class IdeaPresenter < Decidim::Log::BasePresenter
        private

        def action_string
          case action
          when "publish", "unpublish", "update", "send_to_technical_validation"
            "decidim.ideas.admin_log.idea.#{action}"
          else
            super
          end
        end

        def diff_fields_mapping
          {
            state: :string,
            published_at: :date,
            # signature_start_date: :date,
            # signature_end_date: :date,
            description: :i18n,
            title: :i18n,
            hashtag: :string
          }
        end

        def i18n_labels_scope
          "activemodel.attributes.ideas"
        end

        def diff_actions
          super + %w(publish unpublish send_to_technical_validation)
        end
      end
    end
  end
end
