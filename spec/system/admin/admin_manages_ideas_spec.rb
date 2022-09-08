# frozen_string_literal: true

require "spec_helper"

describe "Admin manages ideas", type: :system do
  STATES = Decidim::Idea.states.keys.map(&:to_sym)

  let(:organization) { create(:organization) }
  let(:user) { create(:user, :confirmed, :admin, organization: organization) }
  let(:model_name) { Decidim::Idea.model_name }
  let(:resource_controller) { Decidim::Ideas::Admin::IdeasController }
  let(:type1) { create :ideas_type, organization: organization }
  let(:type2) { create :ideas_type, organization: organization }
  let(:scoped_type1) { create :ideas_type_scope, type: type1 }
  let(:scoped_type2) { create :ideas_type_scope, type: type2 }
  let(:area1) { create :area, organization: organization }
  let(:area2) { create :area, organization: organization }

  def create_idea_with_trait(trait)
    create(:idea, trait, organization: organization)
  end

  def idea_with_state(state)
    Decidim::Idea.find_by(state: state)
  end

  def idea_without_state(state)
    Decidim::Idea.where.not(state: state).sample
  end

  def idea_with_type(type)
    Decidim::Idea.join(:scoped_type).find_by(decidim_ideas_types_id: type)
  end

  def idea_without_type(type)
    Decidim::Idea.join(:scoped_type).where.not(decidim_ideas_types_id: type).sample
  end

  def idea_with_area(area)
    Decidim::Idea.find_by(decidim_area_id: area)
  end

  def idea_without_area(area)
    Decidim::Idea.where.not(decidim_area_id: area).sample
  end

  include_context "with filterable context"

  STATES.each do |state|
    let!("#{state}_idea".to_sym) { create_idea_with_trait(state) }
  end

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
    visit decidim_admin_ideas.ideas_path
  end

  describe "listing ideas" do
    STATES.each do |state|
      i18n_state = I18n.t(state, scope: "decidim.admin.filters.ideas.state_eq.values")

      context "filtering collection by state: #{i18n_state}" do
        it_behaves_like "a filtered collection", options: "State", filter: i18n_state do
          let(:in_filter) { translated(idea_with_state(state).title) }
          let(:not_in_filter) { translated(idea_without_state(state).title) }
        end
      end
    end

    Decidim::IdeasTypeScope.all.each do |scoped_type|
      type = scoped_type.type
      i18n_type = type.title[I18n.locale.to_s]

      context "filtering collection by type: #{i18n_type}" do
        before do
          create(:idea, organization: organization, scoped_type: scoped_type1)
          create(:idea, organization: organization, scoped_type: scoped_type2)
        end

        it_behaves_like "a filtered collection", options: "Type", filter: i18n_type do
          let(:in_filter) { translated(idea_with_type(type).title) }
          let(:not_in_filter) { translated(idea_without_type(type).title) }
        end
      end
    end

    it "can be searched by title" do
      search_by_text(translated(published_idea.title))

      expect(page).to have_content(translated(published_idea.title))
    end

    Decidim::Area.all.each do |area|
      i18n_area = area.name[I18n.locale.to_s]

      context "filtering collection by area: #{i18n_area}" do
        before do
          create(:idea, organization: organization, area: area1)
          create(:idea, organization: organization, area: area2)
        end

        it_behaves_like "a filtered collection", options: "Area", filter: i18n_area do
          let(:in_filter) { translated(idea_with_area(area).title) }
          let(:not_in_filter) { translated(idea_without_area(area).title) }
        end
      end
    end

    it "can be searched by description" do
      search_by_text(translated(published_idea.description))

      expect(page).to have_content(translated(published_idea.title))
    end

    it "can be searched by id" do
      search_by_text(published_idea.id)

      expect(page).to have_content(translated(published_idea.title))
    end

    it "can be searched by author name" do
      search_by_text(published_idea.author.name)

      expect(page).to have_content(translated(published_idea.title))
    end

    it "can be searched by author nickname" do
      search_by_text(published_idea.author.nickname)

      expect(page).to have_content(translated(published_idea.title))
    end

    it_behaves_like "paginating a collection"
  end
end
