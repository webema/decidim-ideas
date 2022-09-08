# frozen_string_literal: true

shared_examples "update an idea type scope" do
  let(:ideas_type_scope) { create(:ideas_type_scope) }
  let(:scope) { create(:scope, organization: ideas_type_scope.type.organization) }

  let(:form) do
    form_klass.from_params(
      form_params
    )
  end

  describe "call" do
    let(:form_params) do
      {
        supports_required: 2000,
        decidim_scopes_id: scope.id
      }
    end

    let(:command) do
      described_class.new(ideas_type_scope, form)
    end

    describe "when the form is not valid" do
      before do
        allow(form).to receive(:invalid?).and_return(true)
      end

      it "broadcasts invalid" do
        expect { command.call }.to broadcast(:invalid)
      end

      it "doesn't update an idea type scope" do
        command.call
        expect(ideas_type_scope.supports_required).not_to eq(form_params[:supports_required])
        expect(ideas_type_scope.decidim_scopes_id).not_to eq(form_params[:decidim_scopes_id])
      end
    end

    describe "when the form is valid" do
      it "broadcasts ok" do
        expect { command.call }.to broadcast(:ok)
      end

      it "updates the idea type scope" do
        command.call

        expect(ideas_type_scope.supports_required).to eq(form_params[:supports_required])
        expect(ideas_type_scope.decidim_scopes_id).to eq(form_params[:decidim_scopes_id])
      end
    end
  end
end
