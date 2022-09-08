# frozen_string_literal: true

require "spec_helper"

describe "Homepage ideas content blocks", type: :system do
  let(:organization) { create(:organization) }
  let!(:idea) { create(:idea, organization: organization) }
  let!(:closed_idea) { create(:idea, :rejected, organization: organization) }

  before do
    create :content_block, organization: organization, scope_name: :homepage, manifest_name: :highlighted_ideas
    switch_to_host(organization.host)
  end

  it "includes active ideas to the homepage" do
    visit decidim.root_path

    within "#highlighted-ideas" do
      expect(page).to have_i18n_content(idea.title)
      expect(page).not_to have_i18n_content(closed_idea.title)
    end
  end
end
