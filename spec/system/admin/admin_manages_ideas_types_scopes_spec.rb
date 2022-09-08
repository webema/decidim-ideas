# frozen_string_literal: true

require "spec_helper"

describe "Admin manages ideas types scopes", type: :system do
  let(:organization) { create(:organization) }
  let(:user) { create(:user, :admin, :confirmed, organization: organization) }
  let(:ideas_type) { create :ideas_type, organization: organization }
  let!(:scope) { create :scope, organization: organization }

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
    visit decidim_admin_ideas.edit_ideas_type_path(ideas_type)
  end

  context "when creating a new idea type scope" do
    it "Creates a new idea type scope" do
      click_link "New Idea type scope"
      scope_pick select_data_picker(:ideas_type_scope_decidim_scopes_id), scope
      fill_in :ideas_type_scope_supports_required, with: 1000
      click_button "Create"

      within ".callout-wrapper" do
        expect(page).to have_content("A new scope for the given idea type has been created")
      end
    end

    it "allows creating idea type scopes with a Global scope" do
      click_link "New Idea type scope"
      fill_in :ideas_type_scope_supports_required, with: 10
      click_button "Create"

      within ".callout-wrapper" do
        expect(page).to have_content("A new scope for the given idea type has been created")
      end

      within ".edit_idea_type" do
        expect(page).to have_content("Global scope")
      end
    end
  end

  context "when editing an idea type scope" do
    let!(:idea_type_scope) { create :ideas_type_scope, type: ideas_type }

    before do
      visit decidim_admin_ideas.edit_ideas_type_path(ideas_type)
    end

    it "updates the idea type scope" do
      click_link "Configure"
      click_button "Update"
      within ".callout-wrapper" do
        expect(page).to have_content("The scope has been successfully updated")
      end
    end

    it "removes the idea type scope" do
      click_link "Configure"
      accept_confirm { click_link "Delete" }
      within ".callout-wrapper" do
        expect(page).to have_content("The scope has been successfully removed")
      end
    end
  end
end
