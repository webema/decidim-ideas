# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Ideas
    describe IdeasPromoted do
      let!(:user) { create(:user, :confirmed, organization: organization) }
      let!(:admin) { create(:user, :confirmed, :admin, organization: organization) }
      let!(:organization) { create(:organization) }
      let!(:user_ideas) { create_list(:idea, 3, organization: organization, author: user) }
      let!(:admin_ideas) { create_list(:idea, 3, organization: organization, author: admin) }

      context "when idea promoters" do
        subject { described_class.new(promoter) }

        let(:promoter) { create(:user, organization: organization) }
        let(:promoter_ideas) { create_list(:idea, 3, organization: organization) }

        before do
          promoter_ideas.each do |idea|
            create(:ideas_committee_member, idea: idea, user: promoter)
          end
        end

        it "includes only promoter ideas" do
          expect(subject).to include(*promoter_ideas)
          expect(subject).not_to include(*user_ideas)
          expect(subject).not_to include(*admin_ideas)
        end
      end
    end
  end
end
