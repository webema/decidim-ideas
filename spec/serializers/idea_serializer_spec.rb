# frozen_string_literal: true

require "spec_helper"

module Decidim::Ideas
  describe IdeaSerializer do
    subject { described_class.new(idea) }

    let(:idea) { create(:idea, :with_area) }
    let(:serialized) { subject.serialize }

    describe "#serialize" do
      it "includes the id" do
        expect(serialized).to include(id: idea.id)
      end

      it "includes the title" do
        expect(serialized).to include(title: idea.title)
      end

      it "includes the description" do
        expect(serialized).to include(description: idea.description)
      end

      it "includes the state" do
        expect(serialized).to include(state: idea.state)
      end

      it "includes the created_at timestamp" do
        expect(serialized).to include(created_at: idea.created_at)
      end

      it "includes the published_at timestamp" do
        expect(serialized).to include(published_at: idea.published_at)
      end

      it "includes the signature_end_date" do
        expect(serialized).to include(signature_end_date: idea.signature_end_date)
      end

      it "includes the signature_type" do
        expect(serialized).to include(signature_type: idea.signature_type)
      end

      it "includes the number of signatures (supports)" do
        expect(serialized).to include(signatures: idea.supports_count)
      end

      it "includes the scope name" do
        expect(serialized[:scope]).to include(name: idea.scope.name)
      end

      it "includes the type title" do
        expect(serialized[:type]).to include(title: idea.type.title)
      end

      it "includes the authors' ids" do
        expect(serialized[:authors]).to include(id: idea.author_users.map(&:id))
      end

      it "includes the authors' names" do
        expect(serialized[:authors]).to include(name: idea.author_users.map(&:name))
      end

      it "includes the area name" do
        expect(serialized[:area]).to include(name: idea.area.name)
      end
    end
  end
end
