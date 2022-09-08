# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Ideas
    describe ExportIdeasJob do
      subject { described_class.perform_now(user, organization, format, collection_ids) }

      let(:format) { "CSV" }
      let(:organization) { create :organization }
      let(:other_organization) { create :organization }
      let!(:user) { create(:user, organization: organization) }
      let!(:ideas) { create_list(:idea, 3, organization: organization) }
      let!(:other_ideas) { create_list(:idea, 3, organization: other_organization) }
      let(:collection_ids) { nil }

      it "sends an email with the result of the export" do
        expect(Decidim::Exporters.find_exporter(format)).to receive(:new)
          .with(
            ideas.sort_by(&:id),
            Decidim::Ideas::IdeaSerializer
          ).and_call_original

        perform_enqueued_jobs do
          subject
        end

        email = last_email
        expect(email.subject).to include("export")
        expect(email.body.encoded).to match("Please find attached a zipped version of your export.")
      end

      context "when a collection of ids is passed as a parameter using an odd ordering" do
        let(:collection_ids) { [ideas.last.id, ideas.first.id] }

        it "sends an email with the result of the export" do
          expect(Decidim::Exporters.find_exporter(format)).to receive(:new)
            .with(
              [ideas.first, ideas.last],
              Decidim::Ideas::IdeaSerializer
            ).and_call_original

          perform_enqueued_jobs do
            subject
          end

          email = last_email
          expect(email.subject).to include("export")
          expect(email.body.encoded).to match("Please find attached a zipped version of your export.")
        end
      end
    end
  end
end
