# frozen_string_literal: true

require "spec_helper"

# We should ideally be using the shared_context for this, but it assumes the
# resource belongs to a component, which is not the case.
describe "Admin manages idea type permissions", type: :system do
  let(:organization) do
    create(
      :organization,
      available_authorizations: %w(dummy_authorization_handler another_dummy_authorization_handler)
    )
  end
  let(:user) { create(:user, :admin, :confirmed, organization: organization) }
  let(:participatory_space_engine) { decidim_admin_ideas }
  let!(:idea_type) { create :ideas_type, organization: organization }

  let(:action) { "vote" }

  let(:index_path) do
    participatory_space_engine.ideas_types_path
  end
  let(:edit_resource_permissions_path) do
    participatory_space_engine
      .edit_ideas_type_permissions_path(
        idea_type.id,
        resource_name: idea_type.resource_manifest.name
      )
  end
  let(:index_class_selector) { ".idea-type-#{idea_type.id}" }
  let(:resource) { idea_type }

  it_behaves_like "manage resource permissions"
end
