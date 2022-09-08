# frozen_string_literal: true

require "spec_helper"
require "decidim/admin/test/manage_attachments_examples"

describe "idea attachments", type: :system do
  describe "when managed by admin" do
    include_context "when admins idea"

    let(:attached_to) { idea }
    let(:attachment_collection) { create(:attachment_collection, collection_for: idea) }

    before do
      switch_to_host(organization.host)
      login_as user, scope: :user
      visit decidim_admin_ideas.edit_idea_path(idea)
      click_link "Attachments"
    end

    it_behaves_like "manage attachments examples"
  end
end
