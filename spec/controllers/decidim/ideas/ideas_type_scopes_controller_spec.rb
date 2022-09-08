# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Ideas
    describe IdeasTypeScopesController, type: :controller do
      routes { Decidim::Ideas::Engine.routes }

      let(:organization) { create(:organization) }
      let(:idea_type) do
        type = create(:ideas_type, organization: organization)

        3.times do
          IdeasTypeScope.create(
            type: type,
            scope: create(:scope, organization: organization),
            supports_required: 1000
          )
        end

        type
      end

      let(:other_idea_type) do
        type = create(:ideas_type, organization: organization)

        3.times do
          IdeasTypeScope.create(
            type: type,
            scope: create(:scope, organization: organization),
            supports_required: 1000
          )
        end

        type
      end

      describe "GET search" do
        it "Returns only scoped types for the given type" do
          expect(other_idea_type.scopes).not_to be_empty

          get :search, params: { type_id: idea_type.id }

          expect(subject.helpers.scoped_types).to include(*idea_type.scopes)
          expect(subject.helpers.scoped_types).not_to include(*other_idea_type.scopes)
        end
      end
    end
  end
end
