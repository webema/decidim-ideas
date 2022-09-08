# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Ideas
    module Admin
      describe ManageableIdeas do
        subject { described_class.for(user) }

        let!(:organization) { create(:organization) }

        let!(:author) { create(:user, organization: organization) }
        let!(:promoter) { create(:user, organization: organization) }
        let!(:admin) { create(:user, :admin, organization: organization) }

        let!(:author_ideas) do
          create_list(:idea, 3, organization: organization, author: author)
        end
        let!(:promoter_ideas) do
          create_list(:idea, 3, organization: organization).each do |idea|
            create(:ideas_committee_member, idea: idea, user: promoter)
          end
        end
        let!(:admin_ideas) do
          create_list(:idea, 3, organization: organization, author: admin)
        end

        context "when idea authors" do
          let(:user) { author }

          it "includes user ideas" do
            expect(subject).to include(*author_ideas)
          end

          it "does not include admin ideas" do
            expect(subject).not_to include(*admin_ideas)
          end
        end

        context "when idea promoters" do
          let(:user) { promoter }

          it "includes promoter ideas" do
            expect(subject).to include(*promoter_ideas)
          end

          it "does not include admin ideas" do
            expect(subject).not_to include(*admin_ideas)
          end
        end

        context "when administrator users" do
          let(:user) { admin }

          it "includes admin ideas" do
            expect(subject).to include(*admin_ideas)
          end

          it "includes user ideas" do
            expect(subject).to include(*author_ideas)
          end

          it "includes promoter ideas" do
            expect(subject).to include(*promoter_ideas)
          end
        end
      end
    end
  end
end
