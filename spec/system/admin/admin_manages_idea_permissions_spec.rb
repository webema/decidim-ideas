# frozen_string_literal: true

require "spec_helper"
# require "decidim/admin/test/manage_component_permissions_examples"

# We should ideally be using the shared_context for this, but it assumes the
# resource belongs to a component, which is not the case.
describe "Admin manages idea permissions", type: :system do
  let(:organization) do
    create(
      :organization,
      available_authorizations: %w(dummy_authorization_handler another_dummy_authorization_handler)
    )
  end
  let(:user) { create(:user, :admin, :confirmed, organization: organization) }
  let(:participatory_space_engine) { decidim_admin_ideas }
  let!(:idea_type) { create(:ideas_type, :online_signature_enabled, organization: organization) }
  let!(:scoped_type) { create(:ideas_type_scope, type: idea_type) }
  let(:idea) { create(:idea, :published, author: author, scoped_type: scoped_type, organization: organization) }
  let!(:author) { create(:user, :confirmed, organization: organization) }

  let(:action) { "comment" }

  let(:index_path) do
    participatory_space_engine.ideas_path
  end
  let(:edit_resource_permissions_path) do
    participatory_space_engine
      .edit_idea_permissions_path(
        idea,
        resource_name: idea.resource_manifest.name
      )
  end
  let(:index_class_selector) { ".idea-#{idea.id}" }
  let(:resource) { idea }

  it_behaves_like "manage resource permissions"
end
