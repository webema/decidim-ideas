# frozen_string_literal: true

require "spec_helper"

describe "Idea signing", type: :system do
  let(:organization) { create(:organization, available_authorizations: authorizations) }
  let(:idea) { create(:idea, :published, organization: organization, scoped_type: create(:ideas_type_scope, type: ideas_type)) }
  let(:ideas_type) { create(:ideas_type, :with_user_extra_fields_collection, :with_sms_code_validation, organization: organization) }
  let(:confirmed_user) { create(:user, :confirmed, organization: organization) }
  let(:authorizations) { ["sms"] }
  let(:document_number) { "0123345678A" }
  let(:phone_number) { "666666666" }
  let!(:verification_form) { Decidim::Verifications::Sms::MobilePhoneForm.new(mobile_phone_number: phone_number) }
  let(:unique_id) { verification_form.unique_id }
  let(:sms_code) { "12345" }
  let!(:authorization) do
    create(
      :authorization,
      :granted,
      name: "dummy_authorization_handler",
      user: confirmed_user,
      unique_id: document_number,
      metadata: { document_number: document_number, postal_code: "01234", scope_id: idea.scope.id }
    )
  end

  before do
    allow(Decidim::Ideas)
      .to receive(:do_not_require_authorization)
      .and_return(true)
    switch_to_host(organization.host)
    login_as confirmed_user, scope: :user
    visit decidim_ideas.idea_path(idea)

    allow(Decidim::Verifications::Sms::MobilePhoneForm).to receive(:new).and_return(verification_form)
    allow(verification_form).to receive(:verification_metadata).and_return(verification_code: sms_code)

    within ".view-side" do
      expect(page).to have_content(signature_text(0))
      click_on "Sign"
    end

    if has_content?("Complete your data")
      fill_in :ideas_vote_name_and_surname, with: confirmed_user.name
      fill_in :ideas_vote_document_number, with: document_number
      select 30.years.ago.year.to_s, from: :ideas_vote_date_of_birth_1i
      select "January", from: :ideas_vote_date_of_birth_2i
      select "1", from: :ideas_vote_date_of_birth_3i
      fill_in :ideas_vote_postal_code, with: "01234"

      click_button "Continue"

      expect(page).to have_no_css("div.alert")
    end
  end

  context "when idea type personal data collection is disabled" do
    let(:ideas_type) { create(:ideas_type, :with_sms_code_validation, organization: organization) }

    it "The sms step appears" do
      expect(page).to have_content("MOBILE PHONE NUMBER")
    end
  end

  context "when personal data collection is enabled" do
    context "when the user has not signed the initiaive yet an signs it" do
      context "when sms authorization is not available for the site" do
        let(:authorizations) { [] }

        it "The vote is created" do
          expect(page).to have_content("idea has been successfully signed")
          click_on "Back to idea"

          within ".view-side" do
            expect(page).to have_content(signature_text(1))
            expect(idea.reload.supports_count).to eq(1)
          end
        end
      end

      it "mobile phone is required" do
        expect(page).to have_content("Fill the form with your verified phone number")
        expect(page).to have_content("Send me an SMS")
        expect(idea.reload.supports_count).to be_zero
      end

      context "when the user fills phone number" do
        context "without authorization" do
          it "phone number is invalid" do
            fill_phone_number

            expect(page).to have_content("The phone number is invalid or pending of authorization")
            expect(idea.reload.supports_count).to be_zero
          end
        end

        context "with valid authorization" do
          before do
            create(:authorization, name: "sms", user: confirmed_user, granted_at: 2.seconds.ago, unique_id: unique_id)
          end

          context "and inserts wrong phone number" do
            let(:unique_id) { "wadus" }

            it "appears an invalid message" do
              fill_phone_number

              expect(page).to have_content("The phone number is invalid or pending of authorization")
              expect(idea.reload.supports_count).to be_zero
            end
          end

          context "and inserts correct phone number" do
            let(:form_sms_code) { sms_code }

            before do
              fill_phone_number
            end

            it "sms code is required" do
              expect(page).to have_content("Check the SMS received at your phone")
              expect(idea.reload.supports_count).to be_zero
            end

            context "and inserts the wrong code number" do
              let(:form_sms_code) { "wadus" }

              it "appears an invalid message" do
                fill_sms_code

                expect(page).to have_content("Your verification code doesn't match ours")
                expect(idea.reload.supports_count).to be_zero
              end
            end

            context "and inserts the correct code number" do
              it "the vote is created" do
                fill_sms_code

                expect(page).to have_content("idea has been successfully signed")
                click_on "Back to idea"

                expect(page).to have_content(signature_text(1))
                expect(idea.reload.supports_count).to eq(1)
              end
            end
          end
        end
      end
    end
  end
end

def fill_phone_number
  fill_in :mobile_phone_mobile_phone_number, with: phone_number
  click_button "Send me an SMS"
end

def fill_sms_code
  fill_in :confirmation_verification_code, with: form_sms_code
  click_button "Check code and continue"
end

def signature_text(number)
  return "1/#{idea.supports_required}\nSIGNATURE" if number == 1

  "#{number}/#{idea.supports_required}\nSIGNATURES"
end
