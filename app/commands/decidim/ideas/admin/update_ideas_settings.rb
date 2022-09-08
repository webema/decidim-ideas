# frozen_string_literal: true

module Decidim
  module Ideas
    module Admin
      # A command with all the business logic when updating ideas
      # settings in admin area.
      class UpdateIdeasSettings < Decidim::Command
        # Public: Initializes the command.
        #
        # ideas_settings - A ideas settings object to update.
        # form - A form object with the params.
        def initialize(ideas_settings, form)
          @ideas_settings = ideas_settings
          @form = form
        end

        # Executes the command. Broadcasts these events:
        #
        # - :ok when everything is valid.
        # - :invalid if the form or ideas_settings isn't valid and we couldn't proceed.
        #
        # Returns nothing.
        def call
          return broadcast(:invalid) if form.invalid? || ideas_settings.invalid?

          update_ideas_settings!

          broadcast(:ok)
        end

        private

        attr_reader :form, :ideas_settings

        def update_ideas_settings!
          Decidim.traceability.update!(
            @ideas_settings,
            form.current_user,
            ideas_order: form.ideas_order
          )
        end
      end
    end
  end
end
