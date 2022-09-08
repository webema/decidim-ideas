# frozen_string_literal: true

require "spec_helper"

describe "User prints the idea", type: :system do
  context "when idea print" do
    include_context "when admins idea"

    before do
      switch_to_host(organization.host)
      login_as user, scope: :user
      visit decidim_admin_ideas.ideas_path
    end

    it "shows a printable form with all available data about the idea" do
      new_window = window_opened_by { page.find(".action-icon--print").click }

      page.within_window(new_window) do
        expect(page).to have_content(translated(idea.title, locale: :en))
        expect(page).to have_content(translated(idea.type.title, locale: :en))
        expect(page).to have_content(ActionView::Base.full_sanitizer.sanitize(translated(idea.description, locale: :en), tags: []))
      end
    end
  end
end
