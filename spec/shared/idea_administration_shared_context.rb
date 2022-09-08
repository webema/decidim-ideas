# frozen_string_literal: true

shared_context "when admins idea" do
  let(:organization) { create(:organization) }
  let(:user) { create(:user, :admin, :confirmed, organization: organization) }
  let(:author) { create(:user, :confirmed, organization: organization) }
  let(:other_ideas_type) { create(:ideas_type, organization: organization, signature_type: "any") }
  let!(:other_ideas_type_scope) { create(:ideas_type_scope, type: other_ideas_type) }

  let(:idea_type) { create(:ideas_type, organization: organization) }
  let(:idea_scope) { create(:ideas_type_scope, type: idea_type) }
  let!(:idea) { create(:idea, organization: organization, scoped_type: idea_scope, author: author) }

  let(:image1_filename) { "city.jpeg" }
  let(:image1_path) { Decidim::Dev.asset(image1_filename) }
  let(:image2_filename) { "city2.jpeg" }
  let(:image2_path) { Decidim::Dev.asset(image2_filename) }
  let(:image3_filename) { "city3.jpeg" }
  let(:image3_path) { Decidim::Dev.asset(image3_filename) }
end
