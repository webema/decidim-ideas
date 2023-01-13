# frozen_string_literal: true

module Decidim
  module Ideas
    module Admin
      # A form object used to manage the idea answer in the
      # administration panel.
      class IdeaAnswerForm < Form
        include TranslatableAttributes

        mimic :idea

        translatable_attribute :answer, String
        attribute :answer_url, String
        attribute :state, String

        def signature_dates_required?
          @signature_dates_required ||= context.idea.state == "published"
        end

        def available_states
          ([current_state] + Decidim::Idea.states.keys.last(5)).compact.map { |state| [I18n.t(state, scope: "decidim.ideas.admin_states"), state] }
        end

        def current_state
          context.idea.state unless Decidim::Idea.states.keys.last(5).include? context.idea.state
        end
      end
    end
  end
end
