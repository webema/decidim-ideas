# frozen_string_literal: true

require "spec_helper"

describe "User prints the idea", type: :system do
  context "when idea print" do
    include_context "when admins idea"
    let(:state) { :created }
    let!(:idea) do
      create(:idea, organization: organization, scoped_type: idea_scope, author: author, state: state)
    end

    before do
      switch_to_host(organization.host)
      login_as author, scope: :user
      visit decidim_ideas.idea_path(idea)

      page.find(".action-print").click
    end

    it "shows a printable form when created" do
      within "main" do
        expect(page).to have_content(translated(idea.title, locale: :en))
        expect(page).to have_content(translated(idea.type.title, locale: :en))
        expect(page).to have_content(ActionView::Base.full_sanitizer.sanitize(translated(idea.description, locale: :en), tags: []))
      end
    end

    context "when sent to technical validation" do
      let(:state) { :validating }

      it "shows a printable form when validating" do
        within "main" do
          expect(page).to have_content(translated(idea.title, locale: :en))
          expect(page).to have_content(translated(idea.type.title, locale: :en))
          expect(page).to have_content(ActionView::Base.full_sanitizer.sanitize(translated(idea.description, locale: :en), tags: []))
        end
      end
    end

    context "and the organization has a logo" do
      let(:organization) { create :organization, logo: Decidim::Dev.test_file("avatar.jpg", "image/jpeg") }

      it "shows a printable form when created" do
        within "main" do
          expect(page).to have_content(translated(idea.title, locale: :en))
          expect(page).to have_content(translated(idea.type.title, locale: :en))
          expect(page).to have_content(ActionView::Base.full_sanitizer.sanitize(translated(idea.description, locale: :en), tags: []))
        end
      end
    end
  end
end
