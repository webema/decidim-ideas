# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe IdeasType do
    let(:ideas_type) { build :ideas_type }

    it "is valid" do
      expect(ideas_type).to be_valid
    end

    describe "::ideas" do
      let(:organization) { create(:organization) }
      let(:ideas_type) { create(:ideas_type, organization: organization) }
      let(:scope) { create(:ideas_type_scope, type: ideas_type) }
      let!(:idea) { create(:idea, organization: organization, scoped_type: scope) }
      let!(:other_idea) { create(:idea) }

      it "returns ideas" do
        expect(ideas_type.ideas).to include(idea)
        expect(ideas_type.ideas).not_to include(other_idea)
      end
    end
  end
end
