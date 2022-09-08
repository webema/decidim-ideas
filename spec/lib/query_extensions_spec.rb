# frozen_string_literal: true

require "spec_helper"
require "decidim/api/test/type_context"

module Decidim
  module Ideas
    describe Decidim::Api::QueryType do
      include_context "with a graphql class type"

      describe "ideasTypes" do
        let!(:ideas_type1) { create(:ideas_type, organization: current_organization) }
        let!(:ideas_type2) { create(:ideas_type, organization: current_organization) }
        let!(:ideas_type3) { create(:ideas_type) }

        let(:query) { %({ ideasTypes { id }}) }

        it "returns all the groups" do
          expect(response["ideasTypes"]).to include("id" => ideas_type1.id.to_s)
          expect(response["ideasTypes"]).to include("id" => ideas_type2.id.to_s)
          expect(response["ideasTypes"]).not_to include("id" => ideas_type3.id.to_s)
        end
      end

      describe "ideasType" do
        let(:model) { create(:ideas_type, organization: current_organization) }
        let(:query) { %({ ideasType(id: \"#{model.id}\") { id }}) }

        it "returns the ideasType" do
          expect(response["ideasType"]).to eq("id" => model.id.to_s)
        end
      end

      describe "ideas" do
        let!(:idea1) { create(:idea, organization: current_organization) }
        let!(:idea2) { create(:idea, organization: current_organization) }
        let!(:idea3) { create(:idea) }

        let(:query) { %({ ideas { id }}) }

        it "returns all the consultations" do
          expect(response["ideas"]).to include("id" => idea1.id.to_s)
          expect(response["ideas"]).to include("id" => idea2.id.to_s)
          expect(response["ideas"]).not_to include("id" => idea3.id.to_s)
        end
      end

      describe "idea" do
        let(:query) { %({ idea(id: \"#{id}\") { id }}) }

        context "with a consultation that belongs to the current organization" do
          let!(:idea) { create(:idea, organization: current_organization) }
          let(:id) { idea.id }

          it "returns the idea" do
            expect(response["idea"]).to eq("id" => idea.id.to_s)
          end
        end

        context "with a conference of another organization" do
          let!(:idea) { create(:idea) }
          let(:id) { idea.id }

          it "returns nil" do
            expect(response["idea"]).to be_nil
          end
        end
      end
    end
  end
end
