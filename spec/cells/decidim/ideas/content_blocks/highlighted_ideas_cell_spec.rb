# frozen_string_literal: true

require "spec_helper"

describe Decidim::Ideas::ContentBlocks::HighlightedIdeasCell, type: :cell do
  subject { cell(content_block.cell, content_block) }

  let(:organization) { create(:organization) }
  let(:content_block) { create :content_block, organization: organization, manifest_name: :highlighted_ideas, scope_name: :homepage, settings: settings }
  let!(:ideas) { create_list :idea, 5, organization: organization }
  let!(:most_recent_idea) { create :idea, published_at: 1.day.from_now, organization: organization }
  let(:settings) { {} }

  let(:highlighted_ideas) { subject.call.find("#highlighted-ideas") }

  controller Decidim::PagesController

  before do
    allow(controller).to receive(:current_organization).and_return(organization)
  end

  context "when the content block has no settings" do
    it "shows 4 ideas" do
      expect(highlighted_ideas).to have_selector("a.card--idea", count: 4)
    end

    it "shows up ideas ordered by default" do
      expect(subject.highlighted_ideas.first).not_to eq(most_recent_idea)
    end
  end

  context "when the content block has customized the max results setting value" do
    let(:settings) do
      {
        "max_results" => "8"
      }
    end

    it "shows up to 8 ideas" do
      expect(highlighted_ideas).to have_selector("a.card--idea", count: 6)
    end
  end

  context "when the content block has customized the sorting order" do
    context "when sorting by most_recent" do
      let(:settings) do
        {
          "order" => "most_recent"
        }
      end

      it "shows up ideas ordered by published_at" do
        expect(subject.highlighted_ideas.first).to eq(most_recent_idea)
      end
    end

    context "when sorting by default (least recent)" do
      let(:settings) do
        {
          "order" => "default"
        }
      end

      it "shows up ideas ordered by published_at" do
        expect(subject.highlighted_ideas.first).not_to eq(most_recent_idea)
      end
    end
  end
end
