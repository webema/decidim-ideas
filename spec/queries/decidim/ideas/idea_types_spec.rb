# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Ideas
    describe IdeaTypes do
      subject { described_class.new(organization) }

      let!(:organization) { create(:organization) }
      let!(:idea_types) { create_list(:ideas_type, 3, organization: organization) }

      let!(:other_organization) { create(:organization) }
      let!(:other_idea_types) { create_list(:ideas_type, 3, organization: other_organization) }

      it "Returns only idea types for the given organization" do
        expect(subject).to include(*idea_types)
        expect(subject).not_to include(*other_idea_types)
      end
    end
  end
end
