# frozen_string_literal: true

require "spec_helper"

describe "User answers the idea", type: :system do
  include_context "when admins idea"

  def submit_and_validate(message = "successfully")
    find("*[type=submit]").click

    within ".callout-wrapper" do
      expect(page).to have_content(message)
    end
  end

  context "when user is admin" do
    before do
      switch_to_host(organization.host)
      login_as user, scope: :user
      visit decidim_admin_ideas.ideas_path
    end

    it "answer is allowed" do
      expect(page).to have_css(".action-icon--answer")
      page.find(".action-icon--answer").click

      within ".edit_idea_answer" do
        fill_in_i18n_editor(
          :idea_answer,
          "#idea-answer-tabs",
          en: "An answer",
          es: "Una respuesta",
          ca: "Una resposta"
        )
      end

      submit_and_validate
    end

    context "when idea is in published state" do
      before do
        idea.published!
      end

      context "and signature dates are editable" do
        it "can be edited in answer" do
          page.find(".action-icon--answer").click

          within ".edit_idea_answer" do
            fill_in_i18n_editor(
              :idea_answer,
              "#idea-answer-tabs",
              en: "An answer",
              es: "Una respuesta",
              ca: "Una resposta"
            )
            expect(page).to have_css("#idea_signature_start_date")
            expect(page).to have_css("#idea_signature_end_date")

            fill_in :idea_signature_start_date, with: 1.day.ago
          end

          submit_and_validate
        end

        context "when dates are invalid" do
          it "returns an error message" do
            page.find(".action-icon--answer").click

            within ".edit_idea_answer" do
              fill_in_i18n_editor(
                :idea_answer,
                "#idea-answer-tabs",
                en: "An answer",
                es: "Una respuesta",
                ca: "Una resposta"
              )
              expect(page).to have_css("#idea_signature_start_date")
              expect(page).to have_css("#idea_signature_end_date")

              fill_in :idea_signature_start_date, with: 1.month.since(idea.signature_end_date)
            end

            submit_and_validate("error")
            expect(page).to have_current_path decidim_admin_ideas.edit_idea_answer_path(idea)
          end
        end
      end
    end

    context "when idea is in validating state" do
      before do
        idea.validating!
      end

      it "signature dates are not displayed" do
        page.find(".action-icon--answer").click

        within ".edit_idea_answer" do
          expect(page).to have_no_css("#idea_signature_start_date")
          expect(page).to have_no_css("#idea_signature_end_date")
        end
      end
    end
  end
end
