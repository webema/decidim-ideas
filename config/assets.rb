# frozen_string_literal: true

base_path = File.expand_path("..", __dir__)

Decidim::Webpacker.register_path("#{base_path}/app/packs")
Decidim::Webpacker.register_entrypoints(
  decidim_ideas: "#{base_path}/app/packs/entrypoints/decidim_ideas.js",
  decidim_ideas_admin: "#{base_path}/app/packs/entrypoints/decidim_ideas_admin.js",
)
Decidim::Webpacker.register_stylesheet_import("stylesheets/decidim/ideas/ideas")
