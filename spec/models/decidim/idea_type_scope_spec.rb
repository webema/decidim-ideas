# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe IdeasTypeScope do
    let(:ideas_type_scope) { build :ideas_type_scope }

    it "is valid" do
      expect(ideas_type_scope).to be_valid
    end

    describe "scope_name" do
      let(:name) { ideas_type_scope.scope_name["en"] }

      context "without a scope" do
        before do
          ideas_type_scope.decidim_scopes_id = nil
        end

        it "returns the global scope name" do
          expect(name).to eq("Global scope")
        end
      end

      context "with an existing scope" do
        it "returns the scope name" do
          expect(name).to eq(ideas_type_scope.scope.name["en"])
        end
      end

      context "with an invalid scope" do
        before do
          ideas_type_scope.decidim_scopes_id = 9999
        end

        it "returns unavailable scope" do
          expect(name).to eq("Unavailable scope")
        end
      end
    end
  end
end
