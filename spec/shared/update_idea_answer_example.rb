# frozen_string_literal: true

shared_examples "update an idea answer" do
  let(:organization) { create(:organization) }
  let(:idea) { create(:idea, organization: organization, state: state) }
  let(:form) do
    form_klass.from_params(
      form_params
    ).with_context(
      current_organization: organization,
      idea: idea
    )
  end
  let(:signature_end_date) { Date.current + 500.days }
  let(:state) { "published" }
  let(:form_params) do
    {
      signature_start_date: Date.current + 10.days,
      signature_end_date: signature_end_date,
      answer: { en: "Measured answer" },
      answer_url: "http://decidim.org"
    }
  end
  let(:administrator) { create(:user, :admin, organization: organization) }
  let(:current_user) { administrator }
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
        command.call

        form_params.each do |key, value|
          expect(idea[key]).not_to eq(value)
        end
      end
    end

    describe "when the form is valid" do
      it "broadcasts ok" do
        expect { command.call }.to broadcast(:ok)
      end

      it "updates the idea" do
        command.call
        idea.reload

        expect(idea.answer["en"]).to eq(form_params[:answer][:en])
        expect(idea.answer_url).to eq(form_params[:answer_url])
      end

      context "when idea is not published" do
        let(:state) { "validating" }

        it "voting interval remains unchanged" do
          command.call
          idea.reload

          [:signature_start_date, :signature_end_date].each do |key|
            expect(idea[key]).not_to eq(form_params[key])
          end
        end
      end

      context "when idea is published" do
        it "voting interval is updated" do
          command.call
          idea.reload

          [:signature_start_date, :signature_end_date].each do |key|
            expect(idea[key]).to eq(form_params[key])
          end
        end
      end
    end
  end
end
