# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Ideas
    describe IdeaHelper do
      context "with state_badge_css_class" do
        let(:idea) { create(:idea) }

        it "success for accepted ideas" do
          allow(idea).to receive(:accepted?).and_return(true)

          expect(helper.state_badge_css_class(idea)).to eq("success")
        end

        it "warning in any other case" do
          allow(idea).to receive(:accepted?).and_return(false)

          expect(helper.state_badge_css_class(idea)).to eq("warning")
        end
      end

      context "with humanize_state" do
        let(:idea) { create(:idea) }

        it "accepted for accepted state" do
          allow(idea).to receive(:accepted?).and_return(true)

          expect(helper.humanize_state(idea)).to eq(I18n.t("accepted", scope: "decidim.ideas.states"))
        end

        it "expired in any other case" do
          allow(idea).to receive(:accepted?).and_return(false)

          expect(helper.humanize_state(idea)).to eq(I18n.t("expired", scope: "decidim.ideas.states"))
        end
      end

      context "with humanize_admin_state" do
        let(:available_states) { [:created, :validating, :discarded, :published, :rejected, :accepted] }

        it "All states have a translation" do
          available_states.each do |state|
            expect(humanize_admin_state(state)).not_to be_blank
          end
        end
      end

      context "with popularity_tag" do
        let(:idea) { build(:idea) }

        it "level1 from 0% to 40%" do
          expect(idea).to receive(:percentage).at_least(:once).and_return(20)
          expect(popularity_tag(idea)).to include("popularity--level1")
        end

        it "level2 from 40% to 60%" do
          expect(idea).to receive(:percentage).at_least(:once).and_return(50)
          expect(popularity_tag(idea)).to include("popularity--level2")
        end

        it "level3 from 60% to 80%" do
          expect(idea).to receive(:percentage).at_least(:once).and_return(70)
          expect(popularity_tag(idea)).to include("popularity--level3")
        end

        it "level4 from 80% to 100%" do
          expect(idea).to receive(:percentage).at_least(:once).and_return(90)
          expect(popularity_tag(idea)).to include("popularity--level4")
        end

        it "level5 at 100%" do
          expect(idea).to receive(:percentage).at_least(:once).and_return(100)
          expect(popularity_tag(idea)).to include("popularity--level5")
        end
      end
    end
  end
end
