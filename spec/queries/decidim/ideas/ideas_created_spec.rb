# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Ideas
    describe IdeasCreated do
      let!(:user) { create(:user, :confirmed, organization: organization) }
      let!(:admin) { create(:user, :confirmed, :admin, organization: organization) }
      let!(:organization) { create(:organization) }
      let!(:user_ideas) { create_list(:idea, 3, organization: organization, author: user) }
      let!(:admin_ideas) { create_list(:idea, 3, organization: organization, author: admin) }

      context "when idea authors" do
        subject { described_class.new(user) }

        it "includes only user ideas" do
          expect(subject).to include(*user_ideas)
          expect(subject).not_to include(*admin_ideas)
        end
      end
    end
  end
end
