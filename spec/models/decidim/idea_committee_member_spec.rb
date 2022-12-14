# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe IdeasCommitteeMember do
    let(:committee_member) { build(:ideas_committee_member) }

    it "is valid" do
      expect(committee_member).to be_valid
    end
  end
end
