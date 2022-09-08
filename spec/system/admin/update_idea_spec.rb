# frozen_string_literal: true

require "spec_helper"

describe "User prints the idea", type: :system do
  include_context "when admins idea"

  def submit_and_validate
    find("*[type=submit]").click

    within ".callout-wrapper" do
      expect(page).to have_content("successfully")
    end
  end

  context "when idea update" do
    context "and user is admin" do
      before do
        switch_to_host(organization.host)
        login_as user, scope: :user
        visit decidim_admin_ideas.ideas_path
      end

      it "Updates published idea data" do
        page.find(".action-icon--edit").click
        within ".edit_idea" do
          fill_in :idea_hashtag, with: "#hashtag"
        end
        submit_and_validate
      end

      context "when idea is in created state" do
        before do
          idea.created!
        end

        it "updates type, scope and signature type" do
          page.find(".action-icon--edit").click
          within ".edit_idea" do
            select translated(other_ideas_type.title), from: "idea_type_id"
            select translated(other_ideas_type_scope.scope.name), from: "idea_decidim_scope_id"
            select "In-person", from: "idea_signature_type"
          end
          submit_and_validate
        end

        it "displays idea attachments" do
          page.find(".action-icon--edit").click
          expect(page).to have_link("Edit")
          expect(page).to have_link("New")
        end
      end

      context "when idea is in validating state" do
        before do
          idea.validating!
        end

        it "updates type, scope and signature type" do
          page.find(".action-icon--edit").click
          within ".edit_idea" do
            select translated(other_ideas_type.title), from: "idea_type_id"
            select translated(other_ideas_type_scope.scope.name), from: "idea_decidim_scope_id"
            select "In-person", from: "idea_signature_type"
          end
          submit_and_validate
        end

        it "displays idea attachments" do
          page.find(".action-icon--edit").click
          expect(page).to have_link("Edit")
          expect(page).to have_link("New")
        end
      end

      context "when idea is in accepted state" do
        before do
          idea.accepted!
        end

        it "update of type, scope and signature type are disabled" do
          page.find(".action-icon--edit").click

          within ".edit_idea" do
            expect(page).to have_css("#idea_type_id[disabled]")
            expect(page).to have_css("#idea_decidim_scope_id[disabled]")
            expect(page).to have_css("#idea_signature_type[disabled]")
          end
        end

        it "displays idea attachments" do
          page.find(".action-icon--edit").click
          expect(page).to have_link("Edit")
          expect(page).to have_link("New")
        end
      end

      context "when there is a single idea type" do
        let!(:other_ideas_type) { nil }
        let!(:other_ideas_type_scope) { nil }

        before do
          idea.created!
        end

        it "update of type, scope and signature type are disabled" do
          page.find(".action-icon--edit").click

          within ".edit_idea" do
            expect(page).not_to have_css("label[for='idea_type_id']")
            expect(page).not_to have_css("#idea_type_id")
          end
        end
      end
    end
  end
end
