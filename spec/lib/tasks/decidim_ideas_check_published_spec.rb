# frozen_string_literal: true

require "spec_helper"

describe "decidim_ideas:check_published", type: :task do
  it "preloads the Rails environment" do
    expect(task.prerequisites).to include "environment"
  end

  it "runs gracefully" do
    expect { task.execute }.not_to raise_error
  end

  context "when ideas with enough votes" do
    let(:idea) { create(:idea, :acceptable) }

    it "is marked as accepted" do
      expect(idea).to be_published

      task.execute
      idea.reload
      expect(idea).to be_accepted
    end
  end

  context "when ideas without enough votes" do
    let(:idea) { create(:idea, :rejectable) }

    it "is marked as rejected" do
      expect(idea).to be_published

      task.execute
      idea.reload
      expect(idea).to be_rejected
    end
  end

  context "when ideas with presential support enabled" do
    let(:idea) { create(:idea, :acceptable, signature_type: "offline") }

    it "keeps unchanged" do
      expect(idea).to be_published

      task.execute
      idea.reload
      expect(idea).to be_published
    end
  end

  context "when ideas with mixed support enabled" do
    let(:idea) { create(:idea, :acceptable, signature_type: "any") }

    it "keeps unchanged" do
      expect(idea).to be_published

      task.execute
      idea.reload
      expect(idea).to be_published
    end
  end
end
