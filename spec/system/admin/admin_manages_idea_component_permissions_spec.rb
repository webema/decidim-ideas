# frozen_string_literal: true

require "spec_helper"
require "decidim/admin/test/manage_component_permissions_examples"

describe "Admin manages idea component permissions", type: :system do
  include_examples "Managing component permissions" do
    let(:user) { create(:user, :admin, :confirmed, organization: organization) }
    let(:participatory_space_engine) { decidim_admin_ideas }

    let!(:participatory_space) do
      create(:idea, organization: organization)
    end
  end
end
