# frozen_string_literal: true

require "spec_helper"

module Decidim::Ideas
  describe Admin::AdminUsers do
    subject { described_class.new(idea) }

    let(:organization) { create :organization }
    let!(:idea) { create :idea, :published, organization: organization }
    let!(:admin) { create(:user, :admin, :confirmed, organization: organization) }
    let!(:normal_user) { create(:user, :confirmed, organization: organization) }
    let!(:other_organization_user) { create(:user, :confirmed) }

    it "returns the organization admins" do
      expect(subject.query).to match_array([admin])
    end
  end
end
