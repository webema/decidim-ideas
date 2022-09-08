# frozen_string_literal: true

module Decidim
  module Ideas
    class IdeasTypeSignatureTypesController < Decidim::Ideas::ApplicationController
      helper_method :allowed_signature_types_for_ideas

      # GET /idea_type_signature_types/search
      def search
        enforce_permission_to :search, :idea_type_signature_types
        render layout: false
      end

      private

      def allowed_signature_types_for_ideas
        @allowed_signature_types_for_ideas ||= IdeasType.find(params[:type_id]).allowed_signature_types_for_ideas
      end
    end
  end
end
