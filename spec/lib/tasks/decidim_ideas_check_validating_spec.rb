# frozen_string_literal: true

require "spec_helper"

describe "decidim_ideas:check_validating", type: :task do
  let(:threshold) { Time.current - Decidim::Ideas.max_time_in_validating_state }

  it "preloads the Rails environment" do
    expect(task.prerequisites).to include "environment"
  end

  it "runs gracefully" do
    expect { task.execute }.not_to raise_error
  end

  context "when ideas without changes" do
    let(:idea) { create(:idea, :validating, updated_at: 1.year.ago) }

    it "Are marked as discarded" do
      expect(idea.updated_at).to be < threshold
      task.execute

      idea.reload
      expect(idea).to be_discarded
    end
  end

  context "when ideas with changes" do
    let(:idea) { create(:idea, :validating) }

    it "remain unchanged" do
      expect(idea.updated_at).to be >= threshold
      task.execute

      idea.reload
      expect(idea).to be_validating
    end
  end
end
