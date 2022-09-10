# frozen_string_literal: true

module Decidim
  module Ideas
    # Exposes the idea type text search so users can choose a type writing its name.
    class IdeasTypeScopesController < Decidim::Ideas::ApplicationController
      helper_method :scoped_types

      # GET /idea_type_scopes/search
      def search
        enforce_permission_to :search, :idea_type_scope
        render layout: false
      end

      private

      def scoped_types
        @scoped_types ||= idea_type.scopes
      end

      def idea_type
        @idea_type ||= IdeasType.find(params[:type_id])
      end
    end
  end
end
