# frozen_string_literal: true

Decidim.register_participatory_space(:ideas) do |participatory_space|
  participatory_space.icon = "media/images/decidim_ideas.svg"
  participatory_space.stylesheet = "decidim/ideas/ideas"

  participatory_space.context(:public) do |context|
    context.engine = Decidim::Ideas::Engine
    context.layout = "layouts/decidim/idea"
  end

  participatory_space.context(:admin) do |context|
    context.engine = Decidim::Ideas::AdminEngine
    context.layout = "layouts/decidim/admin/idea"
  end

  participatory_space.participatory_spaces do |organization|
    Decidim::Idea.where(organization: organization)
  end

  participatory_space.query_type = "Decidim::Ideas::IdeaType"

  participatory_space.register_resource(:idea) do |resource|
    resource.actions = %w(comment)
    resource.permissions_class_name = "Decidim::Ideas::Permissions"
    resource.model_class_name = "Decidim::Idea"
    resource.card = "decidim/ideas/idea"
    resource.searchable = true
  end

  participatory_space.register_resource(:ideas_type) do |resource|
    resource.model_class_name = "Decidim::IdeasType"
    resource.actions = %w(vote)
  end

  participatory_space.model_class_name = "Decidim::Idea"
  participatory_space.permissions_class_name = "Decidim::Ideas::Permissions"

  participatory_space.exports :ideas do |export|
    export.collection do
      Decidim::Idea
    end

    export.serializer Decidim::Ideas::IdeaSerializer
  end

  participatory_space.seeds do
    seeds_root = File.join(__dir__, "..", "..", "..", "db", "seeds")
    organization = Decidim::Organization.first

    Decidim::ContentBlock.create(
      organization: organization,
      weight: 33,
      scope_name: :homepage,
      manifest_name: :highlighted_ideas,
      published_at: Time.current
    )

    3.times do |n|
      type = Decidim::IdeasType.create!(
        title: Decidim::Faker::Localized.sentence(word_count: 5),
        description: Decidim::Faker::Localized.sentence(word_count: 25),
        organization: organization,
        banner_image: ActiveStorage::Blob.create_and_upload!(
          io: File.open(File.join(seeds_root, "city2.jpeg")),
          filename: "banner_image.jpeg",
          content_type: "image/jpeg",
          metadata: nil
        )
      )

      organization.top_scopes.each do |scope|
        Decidim::IdeasTypeScope.create(
          type: type,
          scope: scope,
          # supports_required: (n + 1) * 1000
        )
      end
    end

    Decidim::Idea.states.keys.each do |state|
      Decidim::Idea.skip_callback(:save, :after, :notify_state_change, raise: false)
      Decidim::Idea.skip_callback(:create, :after, :notify_creation, raise: false)

      params = {
        title: Decidim::Faker::Localized.sentence(word_count: 3),
        description: Decidim::Faker::Localized.sentence(word_count: 25),
        scoped_type: Decidim::IdeasTypeScope.reorder(Arel.sql("RANDOM()")).first,
        state: state,
        # signature_type: "online",
        # signature_start_date: Date.current - 7.days,
        # signature_end_date: Date.current + 7.days,
        published_at: 7.days.ago,
        author: Decidim::User.reorder(Arel.sql("RANDOM()")).first,
        organization: organization
      }

      idea = Decidim.traceability.perform_action!(
        "publish",
        Decidim::Idea,
        organization.users.first,
        visibility: "all"
      ) do
        Decidim::Idea.create!(params)
      end
      idea.add_to_index_as_search_resource

      Decidim::Comments::Seed.comments_for(idea)

      Decidim::Attachment.create!(
        title: Decidim::Faker::Localized.sentence(word_count: 2),
        description: Decidim::Faker::Localized.sentence(word_count: 5),
        attached_to: idea,
        content_type: "image/jpeg",
        file: ActiveStorage::Blob.create_and_upload!(
          io: File.open(File.join(seeds_root, "city.jpeg")),
          filename: "city.jpeg",
          content_type: "image/jpeg",
          metadata: nil
        )
      )

      Decidim::Ideas.default_components.each do |component_name|
        component = Decidim::Component.create!(
          name: Decidim::Components::Namer.new(idea.organization.available_locales, component_name).i18n_name,
          manifest_name: component_name,
          published_at: Time.current,
          participatory_space: idea
        )

        next unless component_name == :pages

        Decidim::Pages::CreatePage.call(component) do
          on(:invalid) { raise "Can't create page" }
        end
      end
    end
  end
end
