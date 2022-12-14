# frozen_string_literal: true

module Decidim
  module Ideas
    module Admin
      # A command with all the business logic that updates an
      # existing initiative type scope.
      class UpdateIdeaTypeScope < Decidim::Command
        # Public: Initializes the command.
        #
        # idea_type_scope: Decidim::IdeasTypeScope
        # form - A form object with the params.
        def initialize(idea_type_scope, form)
          @form = form
          @idea_type_scope = idea_type_scope
        end

        # Executes the command. Broadcasts these events:
        #
        # - :ok when everything is valid.
        # - :invalid if the form wasn't valid and we couldn't proceed.
        #
        # Returns nothing.
        def call
          return broadcast(:invalid) if form.invalid?

          idea_type_scope.update(attributes)
          broadcast(:ok, idea_type_scope)
        end

        private

        attr_reader :form, :idea_type_scope

        def attributes
          {
            decidim_scopes_id: form.decidim_scopes_id
          }
        end
      end
    end
  end
end
