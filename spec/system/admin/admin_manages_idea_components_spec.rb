# frozen_string_literal: true

require "spec_helper"

describe "Admin manages idea components", type: :system do
  let(:organization) { create(:organization) }
  let(:user) { create(:user, :admin, :confirmed, organization: organization) }

  let!(:idea) { create(:idea, organization: organization) }

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
  end

  context "when adds a component" do
    before do
      visit decidim_admin_ideas.components_path(idea)

      find("button[data-toggle=add-component-dropdown]").click

      within "#add-component-dropdown" do
        find(".dummy").click
      end

      within ".new_component" do
        fill_in_i18n(
          :component_name,
          "#component-name-tabs",
          en: "My component",
          ca: "El meu component",
          es: "Mi componente"
        )

        within ".global-settings" do
          fill_in_i18n_editor(
            :component_settings_dummy_global_translatable_text,
            "#global-settings-dummy_global_translatable_text-tabs",
            en: "Dummy Text"
          )
          all("input[type=checkbox]").last.click
        end

        within ".default-step-settings" do
          fill_in_i18n_editor(
            :component_default_step_settings_dummy_step_translatable_text,
            "#default-step-settings-dummy_step_translatable_text-tabs",
            en: "Dummy Text for Step"
          )
          all("input[type=checkbox]").first.click
        end

        click_button "Add component"
      end
    end

    it "is successfully created" do
      within ".callout-wrapper" do
        expect(page).to have_content("successfully")
      end

      expect(page).to have_content("My component")
    end

    context "and then edit it" do
      before do
        within find("tr", text: "My component") do
          page.find(".action-icon--configure").click
        end
      end

      it "sucessfully displays initial values in the form" do
        within ".global-settings" do
          expect(all("input[type=checkbox]").last).to be_checked
        end

        within ".default-step-settings" do
          expect(all("input[type=checkbox]").first).to be_checked
        end
      end

      it "successfully edits it" do
        click_button "Update"

        within ".callout-wrapper" do
          expect(page).to have_content("successfully")
        end
      end
    end
  end

  context "when edit a component" do
    let(:component_name) do
      {
        en: "My component",
        ca: "El meu component",
        es: "Mi componente"
      }
    end

    let!(:component) do
      create(:component, name: component_name, participatory_space: idea)
    end

    before do
      visit decidim_admin_ideas.components_path(idea)
    end

    it "updates the component" do
      within ".component-#{component.id}" do
        page.find(".action-icon--configure").click
      end

      within ".edit_component" do
        fill_in_i18n(
          :component_name,
          "#component-name-tabs",
          en: "My updated component",
          ca: "El meu component actualitzat",
          es: "Mi componente actualizado"
        )

        within ".global-settings" do
          all("input[type=checkbox]").last.click
        end

        within ".default-step-settings" do
          all("input[type=checkbox]").first.click
        end

        click_button "Update"
      end

      within ".callout-wrapper" do
        expect(page).to have_content("successfully")
      end

      expect(page).to have_content("My updated component")

      within find("tr", text: "My updated component") do
        page.find(".action-icon--configure").click
      end

      within ".global-settings" do
        expect(all("input[type=checkbox]").last).to be_checked
      end

      within ".default-step-settings" do
        expect(all("input[type=checkbox]").first).to be_checked
      end
    end
  end

  context "when remove a component" do
    let(:component_name) do
      {
        en: "My component",
        ca: "El meu component",
        es: "Mi componente"
      }
    end

    let!(:component) do
      create(:component, name: component_name, participatory_space: idea)
    end

    before do
      visit decidim_admin_ideas.components_path(idea)
    end

    it "removes the component" do
      within ".component-#{component.id}" do
        page.find(".action-icon--remove").click
      end

      expect(page).to have_no_content("My component")
    end
  end

  context "when publish and unpublish a component" do
    let!(:component) do
      create(:component, participatory_space: idea, published_at: published_at)
    end

    let(:published_at) { nil }

    before do
      switch_to_host(organization.host)
      login_as user, scope: :user
      visit decidim_admin_ideas.components_path(idea)
    end

    context "when the component is unpublished" do
      it "publishes the component" do
        within ".component-#{component.id}" do
          page.find(".action-icon--publish").click
        end

        within ".component-#{component.id}" do
          expect(page).to have_css(".action-icon--unpublish")
        end
      end

      it_behaves_like "manage component share tokens"
    end

    context "when the component is published" do
      let(:published_at) { Time.current }

      it "unpublishes the component" do
        within ".component-#{component.id}" do
          page.find(".action-icon--unpublish").click
        end

        within ".component-#{component.id}" do
          expect(page).to have_css(".action-icon--publish")
        end
      end
    end
  end

  def participatory_space
    idea
  end

  def participatory_space_components_path(participatory_space)
    decidim_admin_ideas.components_path(participatory_space)
  end
end
