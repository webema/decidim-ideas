# frozen-string_literal: true

module Decidim
  module Ideas
    class IdeaSentToTechnicalValidationEvent < Decidim::Events::SimpleEvent
      include Rails.application.routes.mounted_helpers

      i18n_attributes :admin_idea_url, :admin_idea_path

      def admin_idea_path
        ResourceLocatorPresenter.new(resource).edit
      end

      def admin_idea_url
        decidim_admin_ideas.edit_idea_url(resource, resource.mounted_params)
      end
    end
  end
end
