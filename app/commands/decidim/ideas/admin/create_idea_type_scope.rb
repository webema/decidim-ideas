# frozen_string_literal: true

module Decidim
  module Ideas
    module Admin
      # A command with all the business logic that creates a new idea type scope
      class CreateIdeaTypeScope < Decidim::Command
        # Public: Initializes the command.
        #
        # form - A form object with the params.
        def initialize(form)
          @form = form
        end

        # Executes the command. Broadcasts these events:
        #
        # - :ok when everything is valid.
        # - :invalid if the form wasn't valid and we couldn't proceed.
        #
        # Returns nothing.
        def call
          return broadcast(:invalid) if form.invalid?

          idea_type_scope = create_idea_type_scope

          if idea_type_scope.persisted?
            broadcast(:ok, idea_type_scope)
          else
            idea_type_scope.errors.each do |error|
              form.errors.add(error.attribute, error.message)
            end

            broadcast(:invalid)
          end
        end

        private

        attr_reader :form

        def create_idea_type_scope
          idea_type = IdeasTypeScope.new(
            decidim_scopes_id: form.decidim_scopes_id,
            decidim_ideas_types_id: form.context.type_id
          )

          return idea_type unless idea_type.valid?

          idea_type.save
          idea_type
        end
      end
    end
  end
end
