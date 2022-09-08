# frozen_string_literal: true

shared_examples "update an idea" do
  let(:organization) { create(:organization) }
  let(:idea) { create(:idea, organization: organization) }

  let(:form) do
    form_klass.from_params(
      form_params
    ).with_context(
      current_organization: organization,
      current_component: nil,
      idea: idea
    )
  end

  let(:signature_end_date) { Date.current + 130.days }
  let(:attachment_params) { nil }
  let(:form_params) do
    {
      title: { en: "A reasonable idea title" },
      description: { en: "A reasonable idea description" },
      signature_start_date: Date.current + 10.days,
      signature_end_date: signature_end_date,
      signature_type: "any",
      type_id: idea.type.id,
      decidim_scope_id: idea.scope.id,
      hashtag: "update_idea_example",
      offline_votes: { idea.scope.id.to_s => 1 },
      attachment: attachment_params
    }
  end
  let(:current_user) { idea.author }

  let(:command) { described_class.new(idea, form, current_user) }

  describe "call" do
    describe "when the form is not valid" do
      before do
        allow(form).to receive(:invalid?).and_return(true)
      end

      it "broadcasts invalid" do
        expect { command.call }.to broadcast(:invalid)
      end

      it "doesn't updates the idea" do
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

        expect(idea.title["en"]).to eq(form_params[:title][:en])
        expect(idea.description["en"]).to eq(form_params[:description][:en])
        expect(idea.type.id).to eq(form_params[:type_id])
        expect(idea.hashtag).to eq(form_params[:hashtag])
      end

      context "when attachment is present" do
        let(:attachment_params) do
          {
            title: "My attachment",
            file: Decidim::Dev.test_file("city.jpeg", "image/jpeg")
          }
        end

        it "creates an atachment for the proposal" do
          expect { command.call }.to change(Decidim::Attachment, :count).by(1)
          last_idea = Decidim::Idea.last
          last_attachment = Decidim::Attachment.last
          expect(last_attachment.attached_to).to eq(last_idea)
        end

        context "when attachment is left blank" do
          let(:attachment_params) do
            {
              title: ""
            }
          end

          it "broadcasts ok" do
            expect { command.call }.to broadcast(:ok)
          end
        end
      end

      it "traces the action", versioning: true do
        expect(Decidim.traceability)
          .to receive(:update!)
          .with(idea, idea.author, kind_of(Hash))
          .and_call_original

        expect { command.call }.to change(Decidim::ActionLog, :count)
        action_log = Decidim::ActionLog.last
        expect(action_log.version).to be_present
      end

      it "voting interval remains unchanged" do
        command.call
        idea.reload

        [:signature_start_date, :signature_end_date].each do |key|
          expect(idea[key]).not_to eq(form_params[key])
        end
      end

      it "offline votes remain unchanged" do
        command.call
        idea.reload
        expect(idea.offline_votes[idea.scope.id.to_s]).not_to eq(form_params[:offline_votes][idea.scope.id.to_s])
      end

      describe "when in created state" do
        let!(:idea) { create(:idea, :created, signature_type: "online") }

        before { form.signature_type = "offline" }

        it "updates signature type" do
          expect { command.call }.to change(idea, :signature_type).from("online").to("offline")
        end
      end

      describe "when not in created state" do
        let!(:idea) { create(:idea, :published, signature_type: "online") }

        before { form.signature_type = "offline" }

        it "doesn't update signature type" do
          expect { command.call }.not_to change(idea, :signature_type)
        end
      end

      context "when administrator user" do
        let(:administrator) { create(:user, :admin, organization: organization) }

        let(:command) do
          described_class.new(idea, form, administrator)
        end

        it "voting interval gets updated" do
          command.call
          idea.reload

          [:signature_start_te, :signature_end_date].each do |key|
            expect(idea[key]).to eq(form_params[key])
          end
        end

        it "offline votes gets updated" do
          command.call
          idea.reload
          expect(idea.offline_votes[idea.scope.id.to_s]).to eq(form_params[:offline_votes][idea.scope.id.to_s])
        end

        it "offline votes maintains a total" do
          command.call
          idea.reload
          expect(idea.offline_votes["total"]).to eq(form_params[:offline_votes][idea.scope.id.to_s])
        end
      end
    end
  end
end
