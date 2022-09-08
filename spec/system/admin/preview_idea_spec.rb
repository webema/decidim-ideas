# frozen_string_literal: true

require "spec_helper"

describe "User previews idea", type: :system do
  include_context "when admins idea"

  context "when idea preview" do
    before do
      switch_to_host(organization.host)
      login_as user, scope: :user
      visit decidim_admin_ideas.ideas_path
    end

    it "shows the details of the given idea" do
      preview_window = window_opened_by do
        page.find(".action-icon--preview").click
      end

      within_window(preview_window) do
        within "main" do
          expect(page).to have_content(translated(idea.title, locale: :en))
          expect(page).to have_content(ActionView::Base.full_sanitizer.sanitize(translated(idea.description, locale: :en), tags: []))
          expect(page).to have_content(translated(idea.type.title, locale: :en))
          expect(page).to have_content(translated(idea.scope.name, locale: :en))
          expect(page).to have_content(idea.author_name)
          expect(page).to have_content(idea.hashtag)
        end
      end
    end
  end
end
