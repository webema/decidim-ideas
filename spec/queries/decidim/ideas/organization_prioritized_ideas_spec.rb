# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Ideas
    describe OrganizationPrioritizedIdeas do
      subject { described_class.new(organization, order) }

      let(:organization) { create(:organization) }
      let!(:user) { create(:user, :confirmed, organization: organization) }
      let!(:ideas) { create_list :idea, 5, organization: organization }
      let!(:most_recent_idea) { create :idea, published_at: 1.day.from_now, organization: organization }

      context "when querying by default order" do
        let(:order) { "default" }

        it "returns ideas ordered by least recent" do
          expect(subject.count).to eq(6)
          expect(subject.query.last).to eq(most_recent_idea)
        end
      end

      context "when querying by most recent order" do
        let(:order) { "most_recent" }

        it "returns ideas ordered by most recent" do
          expect(subject.count).to eq(6)
          expect(subject.query.first).to eq(most_recent_idea)
        end
      end
    end
  end
end
