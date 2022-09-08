# frozen_string_literal: true

module Decidim
  module Ideas
    # Exposes the idea type text search so users can choose a type writing its name.
    class IdeaTypesController < Decidim::Ideas::ApplicationController
      # GET /idea_types/search
      def search
        enforce_permission_to :search, :idea_type

        types = FreetextIdeaTypes.for(current_organization, I18n.locale, params[:term])
        render json: { results: types.map { |type| { id: type.id.to_s, text: type.title[I18n.locale.to_s] } } }
      end
    end
  end
end
