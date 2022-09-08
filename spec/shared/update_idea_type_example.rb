# frozen_string_literal: true

shared_examples "update an idea type" do
  let(:organization) { create(:organization) }
  let(:user) { create(:user) }
  let(:idea_type) do
    create(:ideas_type,
           :online_signature_enabled,
           :attachments_disabled,
           :undo_online_signatures_enabled,
           :custom_signature_end_date_disabled,
           :area_disabled,
           organization: organization)
  end
  let(:form) do
    form_klass.from_params(
      form_params
    ).with_context(
      current_organization: idea_type.organization,
      current_component: nil
    )
  end

  describe "call" do
    let(:form_params) do
      {
        title: Decidim::Faker::Localized.sentence(word_count: 5).except("machine_translations"),
        description: Decidim::Faker::Localized.sentence(word_count: 25).except("machine_translations"),
        signature_type: "offline",
        attachments_enabled: true,
        undo_online_signatures_enabled: false,
        custom_signature_end_date_enabled: true,
        area_enabled: true,
        comments_enabled: true,
        promoting_committee_enabled: true,
        minimum_committee_members: 7,
        banner_image: Decidim::Dev.test_file("city2.jpeg", "image/jpeg"),
        collect_user_extra_fields: false,
        extra_fields_legal_information: Decidim::Faker::Localized.sentence(word_count: 25).except("machine_translations"),
        document_number_authorization_handler: "",
        child_scope_threshold_enabled: false,
        only_global_scope_enabled: false
      }
    end

    let(:command) { described_class.new(idea_type, form, user) }

    describe "when the form is not valid" do
      before do
        allow(form).to receive(:invalid?).and_return(true)
      end

      it "broadcasts invalid" do
        expect { command.call }.to broadcast(:invalid)
      end

      it "doesn't update an idea type" do
        command.call
        expect(idea_type.title).not_to eq(form_params[:title])
        expect(idea_type.description).not_to eq(form_params[:description])
        expect(idea_type.signature_type).not_to eq(form_params[:signature_type])
        expect(idea_type.attachments_enabled).not_to eq(form_params[:attachments_enabled])
        expect(idea_type.undo_online_signatures_enabled).not_to eq(form_params[:undo_online_signatures_enabled])
        expect(idea_type.custom_signature_end_date_enabled).not_to eq(form_params[:custom_signature_end_date_enabled])
        expect(idea_type.area_enabled).not_to eq(form_params[:area_enabled])
        expect(idea_type.minimum_committee_members).not_to eq(form_params[:minimum_committee_members])
      end
    end

    describe "when the form is valid" do
      let(:scope) { create(:ideas_type_scope, type: idea_type) }

      it "broadcasts ok" do
        expect { command.call }.to broadcast(:ok)
      end

      it "updates the idea type" do
        command.call

        expect(idea_type.title.except("machine_translations")).to eq(form_params[:title])
        expect(idea_type.description.except("machine_translations")).to eq(form_params[:description])
        expect(idea_type.signature_type).to eq(form_params[:signature_type])
        expect(idea_type.attachments_enabled).to eq(form_params[:attachments_enabled])
        expect(idea_type.undo_online_signatures_enabled).to eq(form_params[:undo_online_signatures_enabled])
        expect(idea_type.custom_signature_end_date_enabled).to eq(form_params[:custom_signature_end_date_enabled])
        expect(idea_type.area_enabled).to eq(form_params[:area_enabled])
        expect(idea_type.minimum_committee_members).to eq(form_params[:minimum_committee_members])
      end

      it "propagates signature type to created ideas" do
        idea = create(:idea, :created, organization: organization, scoped_type: scope, signature_type: "online")

        command.call
        idea.reload

        expect(idea.signature_type).to eq("offline")
      end

      it "doesn't propagate signature type to non-created ideas" do
        idea = create(:idea, :published, organization: organization, scoped_type: scope, signature_type: "online")

        command.call
        idea.reload

        expect(idea.signature_type).to eq("online")
      end

      it "traces the action", versioning: true do
        expect(Decidim.traceability)
          .to receive(:perform_action!)
          .with("update", idea_type, user)
          .and_call_original

        expect { command.call }.to change(Decidim::ActionLog, :count)
        action_log = Decidim::ActionLog.last
        expect(action_log.action).to eq("update")
        expect(action_log.version).to be_present
      end
    end
  end
end
