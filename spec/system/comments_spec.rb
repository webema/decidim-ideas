# frozen_string_literal: true

require "spec_helper"

describe "Comments", type: :system do
  let(:organization) { create(:organization) }
  let!(:idea_type) { create(:ideas_type, :online_signature_enabled, organization: organization) }
  let!(:scoped_type) { create(:ideas_type_scope, type: idea_type) }
  let(:commentable) { create(:idea, :published, author: user, scoped_type: scoped_type, organization: organization) }
  let!(:participatory_space) { commentable }
  let(:component) { nil }
  let(:resource_path) { resource_locator(commentable).path }

  include_examples "comments"
end
