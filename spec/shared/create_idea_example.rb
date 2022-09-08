# frozen_string_literal: true

shared_examples "create an idea" do
  let(:idea_type) { create(:ideas_type) }
  let(:scoped_type) { create(:ideas_type_scope, type: idea_type) }
  let(:author) { create(:user, organization: idea_type.organization) }
  let(:form) do
    form_klass
      .from_params(form_params)
      .with_context(
        current_organization: idea_type.organization,
        idea_type: idea_type
      )
  end
  let(:uploaded_files) { [] }
  let(:current_files) { [] }

  describe "call" do
    let(:form_params) do
      {
        title: "A reasonable idea title",
        description: "A reasonable idea description",
        type_id: scoped_type.type.id,
        signature_type: "online",
        scope_id: scoped_type.scope.id,
        decidim_user_group_id: nil,
        add_documents: uploaded_files,
        documents: current_files
      }
    end

    let(:command) { described_class.new(form, author) }

    describe "when the form is not valid" do
      before do
        allow(form).to receive(:invalid?).and_return(true)
      end

      it "broadcasts invalid" do
        expect { command.call }.to broadcast(:invalid)
      end

      it "doesn't create an idea" do
        expect do
          command.call
        end.not_to change(Decidim::Idea, :count)
      end
    end

    describe "when the form is valid" do
      it "broadcasts ok" do
        expect { command.call }.to broadcast(:ok)
      end

      it "creates a new idea" do
        expect do
          command.call
        end.to change(Decidim::Idea, :count).by(1)
      end

      context "when attachment is present" do
        let(:uploaded_files) do
          [
            upload_test_file(Decidim::Dev.test_file("Exampledocument.pdf", "application/pdf"))
          ]
        end

        it "creates an attachment for the proposal" do
          expect { command.call }.to change(Decidim::Attachment, :count).by(1)
          last_idea = Decidim::Idea.last
          last_attachment = Decidim::Attachment.last
          expect(last_attachment.attached_to).to eq(last_idea)
        end

        context "when attachment is left blank" do
          it "broadcasts ok" do
            expect { command.call }.to broadcast(:ok)
          end
        end
      end

      context "when has multiple attachments" do
        let(:uploaded_files) do
          [
            upload_test_file(Decidim::Dev.test_file("city.jpeg", "image/jpeg")),
            upload_test_file(Decidim::Dev.test_file("Exampledocument.pdf", "application/pdf"))
          ]
        end

        it "creates multiple attachments for the idea" do
          expect { command.call }.to change(Decidim::Attachment, :count).by(2)
        end
      end

      it "sets the author" do
        command.call
        idea = Decidim::Idea.last

        expect(idea.author).to eq(author)
      end

      it "Default state is created" do
        command.call
        idea = Decidim::Idea.last

        expect(idea).to be_created
      end

      it "Title and description are stored with its locale" do
        command.call
        idea = Decidim::Idea.last

        expect(idea.title.keys).not_to be_empty
        expect(idea.description.keys).not_to be_empty
      end

      it "Voting interval is not set yet" do
        command.call
        idea = Decidim::Idea.last

        expect(idea).not_to have_signature_interval_defined
      end

      it "adds the author as follower" do
        command.call do
          on(:ok) do |assembly|
            expect(author.follows?(assembly)).to be_true
          end
        end
      end

      it "adds the author as committee member in accepted state" do
        command.call
        idea = Decidim::Idea.last

        expect(idea.committee_members.accepted.where(user: author)).to exist
      end

      context "when the idea type does not enable custom signature end date" do
        it "does not set the signature end date" do
          command.call
          idea = Decidim::Idea.last

          expect(idea.signature_end_date).to be_nil
        end
      end

      context "when the idea type enables custom signature end date" do
        let(:idea_type) { create(:ideas_type, :custom_signature_end_date_enabled) }

        let(:form_params) do
          {
            title: "A reasonable idea title",
            description: "A reasonable idea description",
            type_id: scoped_type.type.id,
            signature_type: "online",
            scope_id: scoped_type.scope.id,
            decidim_user_group_id: nil,
            signature_end_date: Date.tomorrow
          }
        end

        it "sets the signature end date" do
          command.call
          idea = Decidim::Idea.last

          expect(idea.signature_end_date).to eq(Date.tomorrow)
        end
      end

      context "when the idea type enables area" do
        let(:idea_type) { create(:ideas_type, :area_enabled) }
        let(:area) { create(:area, organization: idea_type.organization) }

        let(:form_params) do
          {
            title: "A reasonable idea title",
            description: "A reasonable idea description",
            type_id: scoped_type.type.id,
            signature_type: "online",
            scope_id: scoped_type.scope.id,
            decidim_user_group_id: nil,
            area_id: area.id
          }
        end

        it "sets the area" do
          command.call
          idea = Decidim::Idea.last

          expect(idea.decidim_area_id).to eq(area.id)
        end
      end
    end
  end
end
