# frozen_string_literal: true

require "spec_helper"

describe "Edit idea", type: :system do
  let(:organization) { create(:organization) }
  let(:user) { create(:user, :confirmed, organization: organization) }
  let(:idea_title) { translated(idea.title) }
  let(:new_title) { "This is my idea new title" }

  let!(:idea_type) { create(:ideas_type, :online_signature_enabled, organization: organization) }
  let!(:scoped_type) { create(:ideas_type_scope, type: idea_type) }

  let!(:other_idea_type) { create(:ideas_type, organization: organization) }
  let!(:other_scoped_type) { create(:ideas_type_scope, type: idea_type) }

  let(:idea_path) { decidim_ideas.idea_path(idea) }
  let(:edit_idea_path) { decidim_ideas.edit_idea_path(idea) }

  shared_examples "manage update" do
    it "can be updated" do
      visit idea_path

      click_link("Edit", href: edit_idea_path)

      expect(page).to have_content "EDIT IDEA"

      within "form.edit_idea" do
        fill_in :idea_title, with: new_title
        click_button "Update"
      end

      expect(page).to have_content(new_title)
    end
  end

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
  end

  describe "when user is idea author" do
    let(:idea) { create(:idea, :created, author: user, scoped_type: scoped_type, organization: organization) }

    it_behaves_like "manage update"

    it "doesn't show the header's edit link" do
      visit idea_path

      within ".topbar" do
        expect(page).not_to have_link("Edit")
      end
    end

    context "when idea is published" do
      let(:idea) { create(:idea, author: user, scoped_type: scoped_type, organization: organization) }

      it "can't be updated" do
        visit decidim_ideas.idea_path(idea)

        expect(page).not_to have_content "Edit idea"

        visit edit_idea_path

        expect(page).to have_content("not authorized")
      end
    end
  end

  describe "when author is a committee member" do
    let(:idea) { create(:idea, :created, scoped_type: scoped_type, organization: organization) }

    before do
      create(:ideas_committee_member, user: user, idea: idea)
    end

    it_behaves_like "manage update"
  end

  describe "when user is admin" do
    let(:user) { create(:user, :confirmed, :admin, organization: organization) }
    let(:idea) { create(:idea, :created, scoped_type: scoped_type, organization: organization) }

    it_behaves_like "manage update"
  end

  describe "when author is not a committee member" do
    let(:idea) { create(:idea, :created, scoped_type: scoped_type, organization: organization) }

    it "renders an error" do
      visit decidim_ideas.idea_path(idea)

      expect(page).to have_no_content("Edit idea")

      visit edit_idea_path

      expect(page).to have_content("not authorized")
    end
  end
end
