# frozen_string_literal: true

require "spec_helper"
require "decidim/core/test/shared_examples/has_contextual_help"

describe "Ideas", type: :system do
  let(:organization) { create(:organization) }
  let(:base_idea) do
    create(:idea, organization: organization)
  end

  before do
    switch_to_host(organization.host)
  end

  context "when there are some published ideas" do
    let!(:idea) { base_idea }
    let!(:unpublished_idea) do
      create(:idea, :created, organization: organization)
    end

    it_behaves_like "shows contextual help" do
      let(:index_path) { decidim_ideas.ideas_path }
      let(:manifest_name) { :ideas }
    end

    it_behaves_like "editable content for admins" do
      let(:target_path) { decidim_ideas.ideas_path }
    end

    context "when requesting the ideas path" do
      before do
        visit decidim_ideas.ideas_path
      end

      context "when accessing from the homepage" do
        it "the menu link is shown" do
          visit decidim.root_path

          within ".main-nav" do
            expect(page).to have_content("Ideas")
            click_link "Ideas"
          end

          expect(page).to have_current_path(decidim_ideas.ideas_path)
        end
      end

      it "lists all the ideas" do
        within "#ideas-count" do
          expect(page).to have_content("1")
        end

        within "#ideas" do
          expect(page).to have_content(translated(idea.title, locale: :en))
          expect(page).to have_content(idea.author_name, count: 1)
          expect(page).not_to have_content(translated(unpublished_idea.title, locale: :en))
        end
      end

      it "links to the individual idea page" do
        click_link(translated(idea.title, locale: :en))
        expect(page).to have_current_path(decidim_ideas.idea_path(idea))
      end

      it "displays the filter idea type filter" do
        within ".new_filter[action$='/ideas']" do
          expect(page).to have_content(/Type/i)
        end
      end

      context "when there is a unique idea type" do
        let!(:unpublished_idea) { nil }

        it "doesn't display the idea type filter" do
          within ".new_filter[action$='/ideas']" do
            expect(page).not_to have_content(/Type/i)
          end
        end
      end

      context "when there are only closed ideas" do
        let!(:closed_idea) do
          create(:idea, :discarded, organization: organization)
        end
        let(:base_idea) { nil }

        before do
          visit decidim_ideas.ideas_path
        end

        it "displays a warning" do
          expect(page).to have_content("Currently, there are no open ideas, but here you can find all the closed ideas listed.")
        end

        it "shows closed ideas" do
          within "#ideas" do
            expect(page).to have_content(translated(closed_idea.title, locale: :en))
          end
        end
      end
    end

    context "when requesting the ideas path and ideas have attachments but the file is not present" do
      let!(:base_idea) { create(:idea, :with_photos, organization: organization) }

      before do
        idea.attachments.each do |attachment|
          attachment.file.purge
        end
        visit decidim_ideas.ideas_path
      end

      it "lists all the ideas without errors" do
        within "#ideas-count" do
          expect(page).to have_content("1")
        end

        within "#ideas" do
          expect(page).to have_content(translated(idea.title, locale: :en))
          expect(page).to have_content(idea.author_name, count: 1)
          expect(page).not_to have_content(translated(unpublished_idea.title, locale: :en))
        end
      end
    end

    context "when it is an idea with card image enabled" do
      before do
        idea.type.attachments_enabled = true
        idea.type.save!

        create(:attachment, attached_to: idea)

        visit decidim_ideas.ideas_path
      end

      it "shows the card image" do
        within "#idea_#{idea.id}" do
          expect(page).to have_selector(".card__image")
        end
      end
    end
  end
end
