# frozen_string_literal: true

module Decidim
  module Ideas
    module Admin
      # A command with all the business logic that creates a new idea type
      class CreateIdeaType < Decidim::Command
        # Public: Initializes the command.
        #
        # form - A form object with the params.
        def initialize(form, user)
          @form = form
          @user = user
        end

        # Executes the command. Broadcasts these events:
        #
        # - :ok when everything is valid.
        # - :invalid if the form wasn't valid and we couldn't proceed.
        #
        # Returns nothing.
        def call
          return broadcast(:invalid) if form.invalid?

          idea_type = create_idea_type

          if idea_type.persisted?
            broadcast(:ok, idea_type)
          else
            form.errors.add(:banner_image, idea_type.errors[:banner_image]) if idea_type.errors.include? :banner_image
            broadcast(:invalid)
          end
        end

        private

        attr_reader :form

        def create_idea_type
          idea_type = Decidim.traceability.create!(
            IdeasType,
            @user,
            organization: form.current_organization,
            title: form.title,
            description: form.description,
            comments_enabled: form.comments_enabled,
            attachments_enabled: form.attachments_enabled,
            banner_image: form.banner_image,
            active: form.active
          )

          return idea_type unless idea_type.valid?

          idea_type.save
          idea_type
        end
      end
    end
  end
end
