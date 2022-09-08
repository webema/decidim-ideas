# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Ideas
    describe UnvoteIdea do
      describe "User unvotes idea" do
        let(:vote) { create(:idea_user_vote) }
        let(:command) { described_class.new(vote.idea, vote.author) }

        it "broadcasts ok" do
          expect(vote).to be_valid
          expect { command.call }.to broadcast :ok
        end

        it "Removes the vote" do
          expect(vote).to be_valid
          expect do
            command.call
          end.to change(IdeasVote, :count).by(-1)
        end

        it "decreases the vote counter by one" do
          idea = vote.idea
          expect(IdeasVote.count).to eq(1)
          expect do
            command.call
            idea.reload
          end.to change { idea.online_votes_count }.by(-1)
        end
      end
    end
  end
end
