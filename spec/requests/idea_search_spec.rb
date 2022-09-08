# frozen_string_literal: true

require "spec_helper"

RSpec.describe "Idea search", type: :request do
  subject { response.body }

  let(:organization) { create :organization }
  let(:type1) { create :ideas_type, organization: organization }
  let(:type2) { create :ideas_type, organization: organization }
  let(:scoped_type1) { create :ideas_type_scope, type: type1 }
  let(:scoped_type2) { create :ideas_type_scope, type: type2 }
  let(:user1) { create(:user, :confirmed, organization: organization, name: "John McDoggo", nickname: "john_mcdoggo") }
  let(:user2) { create(:user, :confirmed, organization: organization, nickname: "doggotrainer") }
  let(:group1) { create(:user_group, :confirmed, organization: organization, name: "The Doggo House", nickname: "the_doggo_house") }
  let(:group2) { create(:user_group, :confirmed, organization: organization, nickname: "thedoggokeeper") }
  let(:area1) { create(:area, organization: organization) }
  let(:area2) { create(:area, organization: organization) }

  let!(:idea1) { create(:idea, id: 999_999, title: { en: "A doggo" }, scoped_type: scoped_type1, organization: organization) }
  let!(:idea2) { create(:idea, description: { en: "There is a doggo in the office" }, scoped_type: scoped_type2, organization: organization) }
  let!(:idea3) { create(:idea, organization: organization) }
  let!(:area1_idea) { create(:idea, organization: organization, area: area1) }
  let!(:area2_idea) { create(:idea, organization: organization, area: area2) }
  let!(:user1_idea) { create(:idea, organization: organization, author: user1) }
  let!(:user2_idea) { create(:idea, organization: organization, author: user2) }
  let!(:group1_idea) { create(:idea, organization: organization, author: group1) }
  let!(:group2_idea) { create(:idea, organization: organization, author: group2) }
  let!(:closed_idea) { create(:idea, :acceptable, organization: organization) }
  let!(:accepted_idea) { create(:idea, :accepted, organization: organization) }
  let!(:rejected_idea) { create(:idea, :rejected, organization: organization) }
  let!(:answered_rejected_idea) { create(:idea, :rejected, organization: organization, answered_at: Time.current) }
  let!(:created_idea) { create(:idea, :created, organization: organization) }
  let!(:user1_created_idea) { create(:idea, :created, organization: organization, author: user1, signature_start_date: Date.current + 2.days, signature_end_date: Date.current + 22.days) }

  let(:filter_params) { {} }
  let(:request_path) { decidim_ideas.ideas_path }

  before do
    get(
      request_path,
      params: { filter: filter_params },
      headers: { "HOST" => organization.host }
    )
  end

  it "displays all published open ideas by default" do
    expect(subject).to include(translated(idea1.title))
    expect(subject).to include(translated(idea2.title))
    expect(subject).to include(translated(idea3.title))
    expect(subject).to include(translated(area1_idea.title))
    expect(subject).to include(translated(area2_idea.title))
    expect(subject).to include(translated(user1_idea.title))
    expect(subject).to include(translated(user2_idea.title))
    expect(subject).to include(translated(group1_idea.title))
    expect(subject).to include(translated(group2_idea.title))
    expect(subject).not_to include(translated(closed_idea.title))
    expect(subject).not_to include(translated(accepted_idea.title))
    expect(subject).not_to include(translated(rejected_idea.title))
    expect(subject).not_to include(translated(answered_rejected_idea.title))
    expect(subject).not_to include(translated(created_idea.title))
    expect(subject).not_to include(translated(user1_created_idea.title))
  end

  context "when filtering by text" do
    let(:filter_params) { { search_text_cont: search_text } }
    let(:search_text) { "doggo" }

    it "displays the ideas containing the search in the title or the body or the author name or nickname" do
      expect(subject).to include(translated(idea1.title))
      expect(subject).to include(translated(idea2.title))
      expect(subject).not_to include(translated(idea3.title))
      expect(subject).not_to include(translated(area1_idea.title))
      expect(subject).not_to include(translated(area2_idea.title))
      expect(subject).to include(translated(user1_idea.title))
      expect(subject).to include(translated(user2_idea.title))
      expect(subject).to include(translated(group1_idea.title))
      expect(subject).to include(translated(group2_idea.title))
      expect(subject).not_to include(translated(closed_idea.title))
      expect(subject).not_to include(translated(accepted_idea.title))
      expect(subject).not_to include(translated(rejected_idea.title))
      expect(subject).not_to include(translated(answered_rejected_idea.title))
      expect(subject).not_to include(translated(created_idea.title))
      expect(subject).not_to include(translated(user1_created_idea.title))
    end

    context "and the search_text is an idea id" do
      let(:search_text) { idea1.id.to_s }

      it "returns the idea with the searched id" do
        expect(subject).to include(translated(idea1.title))
        expect(subject).not_to include(translated(idea2.title))
        expect(subject).not_to include(translated(idea3.title))
        expect(subject).not_to include(translated(area1_idea.title))
        expect(subject).not_to include(translated(area2_idea.title))
        expect(subject).not_to include(translated(user1_idea.title))
        expect(subject).not_to include(translated(user2_idea.title))
        expect(subject).not_to include(translated(group1_idea.title))
        expect(subject).not_to include(translated(group2_idea.title))
        expect(subject).not_to include(translated(closed_idea.title))
        expect(subject).not_to include(translated(accepted_idea.title))
        expect(subject).not_to include(translated(rejected_idea.title))
        expect(subject).not_to include(translated(answered_rejected_idea.title))
        expect(subject).not_to include(translated(created_idea.title))
        expect(subject).not_to include(translated(user1_created_idea.title))
      end
    end
  end

  context "when filtering by state" do
    let(:filter_params) { { with_any_state: state } }

    context "and state is open" do
      let(:state) { %w(open) }

      it "displays only open ideas" do
        expect(subject).to include(translated(idea1.title))
        expect(subject).to include(translated(idea2.title))
        expect(subject).to include(translated(idea3.title))
        expect(subject).to include(translated(area1_idea.title))
        expect(subject).to include(translated(area2_idea.title))
        expect(subject).to include(translated(user1_idea.title))
        expect(subject).to include(translated(user2_idea.title))
        expect(subject).to include(translated(group1_idea.title))
        expect(subject).to include(translated(group2_idea.title))
        expect(subject).not_to include(translated(closed_idea.title))
        expect(subject).not_to include(translated(accepted_idea.title))
        expect(subject).not_to include(translated(rejected_idea.title))
        expect(subject).not_to include(translated(answered_rejected_idea.title))
        expect(subject).not_to include(translated(created_idea.title))
        expect(subject).not_to include(translated(user1_created_idea.title))
      end
    end

    context "and state is closed" do
      let(:state) { %w(closed) }

      it "displays only closed ideas" do
        expect(subject).not_to include(translated(idea1.title))
        expect(subject).not_to include(translated(idea2.title))
        expect(subject).not_to include(translated(idea3.title))
        expect(subject).not_to include(translated(area1_idea.title))
        expect(subject).not_to include(translated(area2_idea.title))
        expect(subject).not_to include(translated(user1_idea.title))
        expect(subject).not_to include(translated(user2_idea.title))
        expect(subject).not_to include(translated(group1_idea.title))
        expect(subject).not_to include(translated(group2_idea.title))
        expect(subject).to include(translated(closed_idea.title))
        expect(subject).to include(translated(accepted_idea.title))
        expect(subject).to include(translated(rejected_idea.title))
        expect(subject).to include(translated(answered_rejected_idea.title))
        expect(subject).not_to include(translated(created_idea.title))
        expect(subject).not_to include(translated(user1_created_idea.title))
      end
    end

    context "and state is accepted" do
      let(:state) { %w(accepted) }

      it "returns only accepted ideas" do
        expect(subject).not_to include(translated(idea1.title))
        expect(subject).not_to include(translated(idea2.title))
        expect(subject).not_to include(translated(idea3.title))
        expect(subject).not_to include(translated(area1_idea.title))
        expect(subject).not_to include(translated(area2_idea.title))
        expect(subject).not_to include(translated(user1_idea.title))
        expect(subject).not_to include(translated(user2_idea.title))
        expect(subject).not_to include(translated(group1_idea.title))
        expect(subject).not_to include(translated(group2_idea.title))
        expect(subject).not_to include(translated(closed_idea.title))
        expect(subject).to include(translated(accepted_idea.title))
        expect(subject).not_to include(translated(rejected_idea.title))
        expect(subject).not_to include(translated(answered_rejected_idea.title))
        expect(subject).not_to include(translated(created_idea.title))
        expect(subject).not_to include(translated(user1_created_idea.title))
      end
    end

    context "and state is rejected" do
      let(:state) { %w(rejected) }

      it "returns only rejected ideas" do
        expect(subject).not_to include(translated(idea1.title))
        expect(subject).not_to include(translated(idea2.title))
        expect(subject).not_to include(translated(idea3.title))
        expect(subject).not_to include(translated(area1_idea.title))
        expect(subject).not_to include(translated(area2_idea.title))
        expect(subject).not_to include(translated(user1_idea.title))
        expect(subject).not_to include(translated(user2_idea.title))
        expect(subject).not_to include(translated(group1_idea.title))
        expect(subject).not_to include(translated(group2_idea.title))
        expect(subject).not_to include(translated(closed_idea.title))
        expect(subject).not_to include(translated(accepted_idea.title))
        expect(subject).to include(translated(rejected_idea.title))
        expect(subject).to include(translated(answered_rejected_idea.title))
        expect(subject).not_to include(translated(created_idea.title))
        expect(subject).not_to include(translated(user1_created_idea.title))
      end
    end

    context "and state is answered" do
      let(:state) { %w(answered) }

      it "returns only answered ideas" do
        expect(subject).not_to include(translated(idea1.title))
        expect(subject).not_to include(translated(idea2.title))
        expect(subject).not_to include(translated(idea3.title))
        expect(subject).not_to include(translated(area1_idea.title))
        expect(subject).not_to include(translated(area2_idea.title))
        expect(subject).not_to include(translated(user1_idea.title))
        expect(subject).not_to include(translated(user2_idea.title))
        expect(subject).not_to include(translated(group1_idea.title))
        expect(subject).not_to include(translated(group2_idea.title))
        expect(subject).not_to include(translated(closed_idea.title))
        expect(subject).not_to include(translated(accepted_idea.title))
        expect(subject).not_to include(translated(rejected_idea.title))
        expect(subject).to include(translated(answered_rejected_idea.title))
        expect(subject).not_to include(translated(created_idea.title))
        expect(subject).not_to include(translated(user1_created_idea.title))
      end
    end

    context "and state is open or closed" do
      let(:state) { %w(open closed) }

      it "displays only closed ideas" do
        expect(subject).to include(translated(idea1.title))
        expect(subject).to include(translated(idea2.title))
        expect(subject).to include(translated(idea3.title))
        expect(subject).to include(translated(area1_idea.title))
        expect(subject).to include(translated(area2_idea.title))
        expect(subject).to include(translated(user1_idea.title))
        expect(subject).to include(translated(user2_idea.title))
        expect(subject).to include(translated(group1_idea.title))
        expect(subject).to include(translated(group2_idea.title))
        expect(subject).to include(translated(closed_idea.title))
        expect(subject).to include(translated(accepted_idea.title))
        expect(subject).to include(translated(rejected_idea.title))
        expect(subject).to include(translated(answered_rejected_idea.title))
        expect(subject).not_to include(translated(created_idea.title))
        expect(subject).not_to include(translated(user1_created_idea.title))
      end
    end
  end

  context "when filtering by scope" do
    let(:filter_params) { { with_any_scope: scope_id } }

    context "and a single scope id is provided" do
      let(:scope_id) { [scoped_type1.scope.id] }

      it "displays ideas by scope" do
        expect(subject).to include(translated(idea1.title))
        expect(subject).not_to include(translated(idea2.title))
        expect(subject).not_to include(translated(idea3.title))
        expect(subject).not_to include(translated(area1_idea.title))
        expect(subject).not_to include(translated(area2_idea.title))
        expect(subject).not_to include(translated(user1_idea.title))
        expect(subject).not_to include(translated(user2_idea.title))
        expect(subject).not_to include(translated(group1_idea.title))
        expect(subject).not_to include(translated(group2_idea.title))
        expect(subject).not_to include(translated(closed_idea.title))
        expect(subject).not_to include(translated(accepted_idea.title))
        expect(subject).not_to include(translated(rejected_idea.title))
        expect(subject).not_to include(translated(answered_rejected_idea.title))
        expect(subject).not_to include(translated(created_idea.title))
        expect(subject).not_to include(translated(user1_created_idea.title))
      end
    end

    context "and multiple scope ids are provided" do
      let(:scope_id) { [scoped_type2.scope.id, scoped_type1.scope.id] }

      it "displays ideas by scope" do
        expect(subject).to include(translated(idea1.title))
        expect(subject).to include(translated(idea2.title))
        expect(subject).not_to include(translated(idea3.title))
        expect(subject).not_to include(translated(area1_idea.title))
        expect(subject).not_to include(translated(area2_idea.title))
        expect(subject).not_to include(translated(user1_idea.title))
        expect(subject).not_to include(translated(user2_idea.title))
        expect(subject).not_to include(translated(group1_idea.title))
        expect(subject).not_to include(translated(group2_idea.title))
        expect(subject).not_to include(translated(closed_idea.title))
        expect(subject).not_to include(translated(accepted_idea.title))
        expect(subject).not_to include(translated(rejected_idea.title))
        expect(subject).not_to include(translated(answered_rejected_idea.title))
        expect(subject).not_to include(translated(created_idea.title))
        expect(subject).not_to include(translated(user1_created_idea.title))
      end
    end
  end

  context "when filtering by author" do
    let(:filter_params) { { with_any_state: %w(open closed), author: author } }

    before do
      login_as user1, scope: :user

      get(
        request_path,
        params: { filter: filter_params },
        headers: { "HOST" => organization.host }
      )
    end

    context "and author is any" do
      let(:author) { "any" }

      it "displays all ideas except the created ones" do
        expect(subject).to include(translated(idea1.title))
        expect(subject).to include(translated(idea2.title))
        expect(subject).to include(translated(idea3.title))
        expect(subject).to include(translated(area1_idea.title))
        expect(subject).to include(translated(area2_idea.title))
        expect(subject).to include(translated(user1_idea.title))
        expect(subject).to include(translated(user2_idea.title))
        expect(subject).to include(translated(group1_idea.title))
        expect(subject).to include(translated(group2_idea.title))
        expect(subject).to include(translated(closed_idea.title))
        expect(subject).to include(translated(accepted_idea.title))
        expect(subject).to include(translated(rejected_idea.title))
        expect(subject).to include(translated(answered_rejected_idea.title))
        expect(subject).not_to include(translated(created_idea.title))
        expect(subject).not_to include(translated(user1_created_idea.title))
      end
    end

    context "and author is myself" do
      let(:author) { "myself" }

      it "contains only ideas of the author, including their created upcoming idea" do
        expect(subject).not_to include(translated(idea1.title))
        expect(subject).not_to include(translated(idea2.title))
        expect(subject).not_to include(translated(idea3.title))
        expect(subject).not_to include(translated(area1_idea.title))
        expect(subject).not_to include(translated(area2_idea.title))
        expect(subject).to include(translated(user1_idea.title))
        expect(subject).not_to include(translated(user2_idea.title))
        expect(subject).not_to include(translated(group1_idea.title))
        expect(subject).not_to include(translated(group2_idea.title))
        expect(subject).not_to include(translated(closed_idea.title))
        expect(subject).not_to include(translated(accepted_idea.title))
        expect(subject).not_to include(translated(rejected_idea.title))
        expect(subject).not_to include(translated(answered_rejected_idea.title))
        expect(subject).not_to include(translated(created_idea.title))
        expect(subject).to include(translated(user1_created_idea.title))
      end
    end
  end

  context "when filtering by type" do
    let(:filter_params) { { with_any_type: type_id } }
    let(:type_id) { [idea1.type.id] }

    it "displays ideas of correct type" do
      expect(subject).to include(translated(idea1.title))
      expect(subject).not_to include(translated(idea2.title))
      expect(subject).not_to include(translated(idea3.title))
      expect(subject).not_to include(translated(area1_idea.title))
      expect(subject).not_to include(translated(area2_idea.title))
      expect(subject).not_to include(translated(user1_idea.title))
      expect(subject).not_to include(translated(user2_idea.title))
      expect(subject).not_to include(translated(group1_idea.title))
      expect(subject).not_to include(translated(group2_idea.title))
      expect(subject).not_to include(translated(closed_idea.title))
      expect(subject).not_to include(translated(accepted_idea.title))
      expect(subject).not_to include(translated(rejected_idea.title))
      expect(subject).not_to include(translated(answered_rejected_idea.title))
      expect(subject).not_to include(translated(created_idea.title))
      expect(subject).not_to include(translated(user1_created_idea.title))
    end

    context "and providing multiple types" do
      let(:type_id) { [idea1.type.id, idea2.type.id] }

      it "displays ideas of correct type" do
        expect(subject).to include(translated(idea1.title))
        expect(subject).to include(translated(idea2.title))
        expect(subject).not_to include(translated(idea3.title))
        expect(subject).not_to include(translated(area1_idea.title))
        expect(subject).not_to include(translated(area2_idea.title))
        expect(subject).not_to include(translated(user1_idea.title))
        expect(subject).not_to include(translated(user2_idea.title))
        expect(subject).not_to include(translated(group1_idea.title))
        expect(subject).not_to include(translated(group2_idea.title))
        expect(subject).not_to include(translated(closed_idea.title))
        expect(subject).not_to include(translated(accepted_idea.title))
        expect(subject).not_to include(translated(rejected_idea.title))
        expect(subject).not_to include(translated(answered_rejected_idea.title))
        expect(subject).not_to include(translated(created_idea.title))
        expect(subject).not_to include(translated(user1_created_idea.title))
      end
    end
  end

  context "when filtering by area" do
    let(:filter_params) { { with_any_area: area_id } }

    context "when an area id is being sent" do
      let(:area_id) { [area1.id.to_s] }

      it "displays ideas by area" do
        expect(subject).not_to include(translated(idea1.title))
        expect(subject).not_to include(translated(idea2.title))
        expect(subject).not_to include(translated(idea3.title))
        expect(subject).to include(translated(area1_idea.title))
        expect(subject).not_to include(translated(area2_idea.title))
        expect(subject).not_to include(translated(user1_idea.title))
        expect(subject).not_to include(translated(user2_idea.title))
        expect(subject).not_to include(translated(group1_idea.title))
        expect(subject).not_to include(translated(group2_idea.title))
        expect(subject).not_to include(translated(closed_idea.title))
        expect(subject).not_to include(translated(accepted_idea.title))
        expect(subject).not_to include(translated(rejected_idea.title))
        expect(subject).not_to include(translated(answered_rejected_idea.title))
        expect(subject).not_to include(translated(created_idea.title))
        expect(subject).not_to include(translated(user1_created_idea.title))
      end
    end

    context "and providing multiple ids" do
      let(:area_id) { [area1.id.to_s, area2.id.to_s] }

      it "displays ideas by area" do
        expect(subject).not_to include(translated(idea1.title))
        expect(subject).not_to include(translated(idea2.title))
        expect(subject).not_to include(translated(idea3.title))
        expect(subject).to include(translated(area1_idea.title))
        expect(subject).to include(translated(area2_idea.title))
        expect(subject).not_to include(translated(user1_idea.title))
        expect(subject).not_to include(translated(user2_idea.title))
        expect(subject).not_to include(translated(group1_idea.title))
        expect(subject).not_to include(translated(group2_idea.title))
        expect(subject).not_to include(translated(closed_idea.title))
        expect(subject).not_to include(translated(accepted_idea.title))
        expect(subject).not_to include(translated(rejected_idea.title))
        expect(subject).not_to include(translated(answered_rejected_idea.title))
        expect(subject).not_to include(translated(created_idea.title))
        expect(subject).not_to include(translated(user1_created_idea.title))
      end
    end
  end
end
