# frozen_string_literal: true

require "spec_helper"

describe "Explore versions", versioning: true, type: :system do
  let(:organization) { create(:organization) }
  let(:idea) { create(:idea, organization: organization) }
  let(:user) { create(:user, :admin, :confirmed, organization: organization) }

  let(:form) do
    Decidim::Ideas::Admin::IdeaForm.from_params(
      title: { en: "A reasonable idea title" },
      description: { en: "A reasonable idea description" },
      signature_start_date: idea.signature_start_date,
      signature_end_date: idea.signature_end_date
    ).with_context(
      current_organization: organization,
      current_component: nil,
      idea: idea
    )
  end
  let(:command) { Decidim::Ideas::Admin::UpdateIdea.new(idea, form, user) }
  let(:idea_path) { decidim_ideas.idea_path(idea) }

  before do
    switch_to_host(organization.host)
  end

  context "when visiting an idea details" do
    it "has only one version" do
      visit idea_path

      expect(page).to have_content("Version number 1 (of 1)")
    end

    it "shows the versions index" do
      visit idea_path

      expect(page).to have_link "see other versions"
    end

    context "when updating an idea" do
      before do
        command.call
      end

      it "creates a new version" do
        visit idea_path

        expect(page).to have_content("Version number 2 (of 2)")
      end
    end
  end

  context "when visiting versions index" do
    before do
      command.call
      visit idea_path
      click_link "see other versions"
    end

    it "lists all versions" do
      expect(page).to have_link("Version 1")
      expect(page).to have_link("Version 2")
    end

    it "shows the versions count" do
      expect(page).to have_content("VERSIONS\n2")
    end

    it "allows going back to the idea" do
      click_link "Go back to idea"
      expect(page).to have_current_path idea_path, ignore_query: true
    end

    it "shows the creation date" do
      within ".card--list__item:last-child" do
        expect(page).to have_content(Time.zone.today.strftime("%d/%m/%Y"))
      end
    end
  end

  context "when showing version" do
    before do
      command.call
      visit idea_path
      click_link "see other versions"

      within ".card--list__item:last-child" do
        first(:link, "Version 2").click
      end
    end

    it_behaves_like "accessible page"

    it "shows the version number" do
      expect(page).to have_content("VERSION NUMBER\n2 out of 2")
    end

    it "allows going back to the idea" do
      click_link "Go back to idea"
      expect(page).to have_current_path idea_path, ignore_query: true
    end

    it "allows going back to the versions list" do
      click_link "Show all versions"
      expect(page).to have_current_path "#{idea_path}/versions"
    end

    it "shows the creation date" do
      within ".card.extra.definition-data" do
        expect(page).to have_content(Time.zone.today.strftime("%d/%m/%Y"))
      end
    end

    it "shows the changed attributes" do
      expect(page).to have_content("Changes at")

      within ".diff-for-title-english" do
        expect(page).to have_content("TITLE")

        within ".diff > ul > .ins" do
          expect(page).to have_content(translated(idea.title, locale: :en))
        end
      end

      within ".diff-for-description-english" do
        expect(page).to have_content("DESCRIPTION")

        within ".diff > ul > .ins" do
          expect(page).to have_content(ActionView::Base.full_sanitizer.sanitize(translated(idea.description, locale: :en), tags: []))
        end
      end
    end
  end
end
