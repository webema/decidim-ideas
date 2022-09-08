# frozen_string_literal: true

module Decidim
  module Ideas
    class ExportIdeasJob < ApplicationJob
      queue_as :exports

      def perform(user, organization, format, collection_ids = nil)
        export_data = Decidim::Exporters.find_exporter(format).new(
          collection_to_export(collection_ids, organization),
          serializer
        ).export

        ExportMailer.export(user, "ideas", export_data).deliver_now
      end

      private

      def collection_to_export(ids, organization)
        collection = Decidim::Idea.where(organization: organization)

        collection = collection.where(id: ids) if ids.present?

        collection.order(id: :asc)
      end

      def serializer
        Decidim::Ideas::IdeaSerializer
      end
    end
  end
end
