# frozen_string_literal: true

require "spec_helper"

describe "Admin manages ideas types", type: :system do
  let(:organization) { create(:organization) }
  let(:user) { create(:user, :admin, :confirmed, organization: organization) }
  let!(:ideas_type) { create(:ideas_type, organization: organization) }

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
    visit decidim_admin_ideas.ideas_types_path
  end

  context "when accessing idea types list" do
    it "shows the idea type data" do
      expect(page).to have_i18n_content(ideas_type.title)
    end
  end

  context "when creating an idea type" do
    it "creates the idea type" do
      click_link "New idea type"

      fill_in_i18n(
        :ideas_type_title,
        "#ideas_type-title-tabs",
        en: "My idea type"
      )

      fill_in_i18n_editor(
        :ideas_type_description,
        "#ideas_type-description-tabs",
        en: "A longer description"
      )

      select("Online", from: "Signature type")

      dynamically_attach_file(:ideas_type_banner_image, Decidim::Dev.asset("city2.jpeg"))

      click_button "Create"

      within ".callout-wrapper" do
        expect(page).to have_content("A new idea type has been successfully created")
      end
    end
  end

  context "when updating an idea type" do
    it "updates the idea type" do
      within find("tr", text: translated(ideas_type.title)) do
        page.find(".action-icon--edit").click
      end

      fill_in_i18n(
        :ideas_type_title,
        "#ideas_type-title-tabs",
        en: "My updated idea type"
      )

      select("Mixed", from: "Signature type")
      check "Enable attachments"
      uncheck "Enable participants to undo their online signatures"
      check "Enable authors to choose the end of signature collection period"
      check "Enable authors to choose the area for their idea"
      uncheck "Enable comments"

      click_button "Update"

      within ".callout-wrapper" do
        expect(page).to have_content("The idea type has been successfully updated")
      end
    end
  end

  context "when deleting an idea type" do
    it "deletes the idea type" do
      within find("tr", text: translated(ideas_type.title)) do
        accept_confirm do
          page.find(".action-icon--remove").click
        end
      end

      within ".callout-wrapper" do
        expect(page).to have_content("The idea type has been successfully removed")
      end
    end
  end
end
