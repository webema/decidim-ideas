# frozen_string_literal: true

require "spec_helper"

describe "Idea", type: :system do
  let(:organization) { create(:organization) }
  let(:state) { :published }
  let(:base_idea) do
    create(:idea, organization: organization, state: state)
  end

  before do
    switch_to_host(organization.host)
  end

  context "when the idea does not exist" do
    it_behaves_like "a 404 page" do
      let(:target_path) { decidim_ideas.idea_path(99_999_999) }
    end
  end

  describe "idea page" do
    let!(:idea) { base_idea }
    let(:attached_to) { idea }

    it_behaves_like "editable content for admins" do
      let(:target_path) { decidim_ideas.idea_path(idea) }
    end

    context "when requesting the idea path" do
      before do
        visit decidim_ideas.idea_path(idea)
      end

      shared_examples_for "idea shows signatures" do
        it "shows signatures for the state" do
          expect(page).to have_css(".progress__bar__number")
          expect(page).to have_css(".progress__bar__text")
        end
      end

      shared_examples_for "idea does not show signatures" do
        it "does not show signatures for the state" do
          expect(page).not_to have_css(".progress__bar__number")
          expect(page).not_to have_css(".progress__bar__text")
        end
      end

      it "shows the details of the given idea" do
        within "main" do
          expect(page).to have_content(translated(idea.title, locale: :en))
          expect(page).to have_content(ActionView::Base.full_sanitizer.sanitize(translated(idea.description, locale: :en), tags: []))
          expect(page).to have_content(translated(idea.type.title, locale: :en))
          expect(page).to have_content(translated(idea.scope.name, locale: :en))
          expect(page).to have_content(idea.author_name)
          expect(page).to have_content(idea.hashtag)
          expect(page).to have_content(idea.reference)
        end
      end

      context "when signature interval is defined" do
        let(:base_idea) do
          create(:idea,
                 organization: organization,
                 signature_start_date: 1.day.ago,
                 signature_end_date: 1.day.from_now,
                 state: state)
        end

        it "displays collection period" do
          within ".process-header__phase" do
            expect(page).to have_content("Signature collection period")
            expect(page).to have_content(1.day.ago.strftime("%Y-%m-%d"))
            expect(page).to have_content(1.day.from_now.strftime("%Y-%m-%d"))
          end
        end
      end

      it_behaves_like "idea shows signatures"

      it "shows the author name once in the authors list" do
        within ".idea-authors" do
          expect(page).to have_content(idea.author_name, count: 1)
        end
      end

      context "when idea state is rejected" do
        let(:state) { :rejected }

        it_behaves_like "idea shows signatures"
      end

      context "when idea state is accepted" do
        let(:state) { :accepted }

        it_behaves_like "idea shows signatures"
      end

      context "when idea state is created" do
        let(:state) { :created }

        it_behaves_like "idea does not show signatures"
      end

      context "when idea state is validating" do
        let(:state) { :validating }

        it_behaves_like "idea does not show signatures"
      end

      context "when idea state is discarded" do
        let(:state) { :discarded }

        it_behaves_like "idea does not show signatures"
      end

      it_behaves_like "has attachments"

      it "displays comments section" do
        expect(page).to have_css(".comments")
        expect(page).to have_content("0 Comments")
      end

      context "when comments are disabled" do
        let(:base_idea) do
          create(:idea, organization: organization, state: state, scoped_type: scoped_type)
        end

        let(:scoped_type) do
          create(:ideas_type_scope,
                 type: create(:ideas_type,
                              :with_comments_disabled,
                              organization: organization,
                              signature_type: "online"))
        end

        it "does not have comments" do
          expect(page).not_to have_css(".comments")
          expect(page).not_to have_content("0 Comments")
        end
      end
    end
  end
end
