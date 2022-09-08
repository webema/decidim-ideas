# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Ideas
    describe IdeasMailer, type: :mailer do
      let(:idea) { create(:idea) }

      context "when notifies creation" do
        let(:mail) { IdeasMailer.notify_creation(idea) }

        it "renders the headers" do
          expect(mail.subject).to eq("Your idea '#{idea.title["en"]}' has been created")
          expect(mail.to).to eq([idea.author.email])
        end

        it "renders the body" do
          expect(mail.body.encoded).to match(idea.title["en"])
        end
      end

      context "when notifies state change" do
        let(:mail) { IdeasMailer.notify_state_change(idea, idea.author) }

        it "renders the headers" do
          expect(mail.subject).to eq("The idea #{idea.title["en"]} has changed its status")
          expect(mail.to).to eq([idea.author.email])
        end

        it "renders the body" do
          expect(mail.body).to match("The idea #{idea.title["en"]} has changed its status to: #{I18n.t(idea.state, scope: "decidim.ideas.admin_states")}")
        end
      end

      context "when notifies progress" do
        let(:mail) { IdeasMailer.notify_progress(idea, idea.author) }

        it "renders the headers" do
          expect(mail.subject).to eq("Summary about the idea: #{idea.title["en"]}")
          expect(mail.to).to eq([idea.author.email])
        end

        it "renders the body" do
          expect(mail.body.encoded).to match(idea.title["en"])
        end
      end
    end
  end
end
