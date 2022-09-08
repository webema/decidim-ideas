# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Ideas
    describe UpdateIdea do
      let(:form_klass) { Decidim::Ideas::IdeaForm }
      let(:organization) { create(:organization) }
      let!(:idea) { create(:idea, organization: organization) }
      let!(:form) do
        form_klass.from_params(
          form_params
        ).with_context(
          current_organization: organization,
          idea: idea,
          idea_type: idea.type
        )
      end
      let(:signature_type) { "online" }
      let(:hashtag) { nil }
      let(:attachment) { nil }
      let(:uploaded_files) { [] }
      let(:current_files) { [] }

      describe "call" do
        let(:title) { "Changed Title" }
        let(:description) { "Changed description" }
        let(:type_id) { idea.type.id }
        let(:form_params) do
          {
            title: title,
            description: description,
            signature_type: signature_type,
            type_id: type_id,
            attachment: attachment,
            add_documents: uploaded_files,
            documents: current_files
          }
        end
        let(:command) do
          described_class.new(idea, form, idea.author)
        end

        describe "when the form is not valid" do
          before do
            allow(form).to receive(:invalid?).and_return(true)
          end

          it "broadcasts invalid" do
            expect { command.call }.to broadcast(:invalid)
          end

          it "doesn't update the idea" do
            expect do
              command.call
            end.not_to change(idea, :title)
          end
        end

        describe "when the form is valid" do
          it "broadcasts ok" do
            expect { command.call }.to broadcast(:ok)
          end

          it "updates the idea" do
            command.call
            idea.reload
            expect(idea.title).to be_kind_of(Hash)
            expect(idea.title["en"]).to eq title
            expect(idea.description).to be_kind_of(Hash)
            expect(idea.description["en"]).to eq description
          end

          context "when attachments are allowed" do
            let(:uploaded_files) do
              [
                upload_test_file(Decidim::Dev.test_file("Exampledocument.pdf", "application/pdf")),
                upload_test_file(Decidim::Dev.test_file("Exampledocument.pdf", "application/pdf"))
              ]
            end

            it "creates multiple atachments for the idea" do
              expect { command.call }.to change(Decidim::Attachment, :count).by(2)
              idea.reload
              last_attachment = Decidim::Attachment.last
              expect(last_attachment.attached_to).to eq(idea)
            end

            context "when the idea already had some attachments" do
              let!(:document) { create(:attachment, :with_pdf, attached_to: idea) }
              let(:current_files) { [document.id] }

              it "keeps the new and old attachments" do
                command.call
                idea.reload
                expect(idea.documents.count).to eq(3)
              end

              context "when the old attachments are deleted by the user" do
                let(:current_files) { [] }

                it "deletes the old attachments" do
                  command.call
                  idea.reload
                  expect(idea.documents.count).to eq(2)
                  expect(idea.documents).not_to include(document)
                end
              end
            end
          end

          context "when attachments are allowed and file is invalid" do
            let(:uploaded_files) do
              [
                upload_test_file(Decidim::Dev.test_file("city.jpeg", "image/jpeg")),
                upload_test_file(Decidim::Dev.test_file("verify_user_groups.csv", "text/csv"))
              ]
            end

            it "does not create atachments for the idea" do
              expect { command.call }.not_to change(Decidim::Attachment, :count)
            end

            it "broadcasts invalid" do
              expect { command.call }.to broadcast(:invalid)
            end
          end
        end
      end
    end
  end
end
