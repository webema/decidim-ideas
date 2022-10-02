# frozen_string_literal: true

$LOAD_PATH.push File.expand_path("lib", __dir__)

require "decidim/ideas/version"

Gem::Specification.new do |s|
  s.version = Decidim::Ideas::VERSION
  s.authors = ['Heiner Sameisky'] # ["Juan Salvador Perez Garcia"]
  s.email = ["hei.sam@@gmail.com"]
  s.license = "AGPL-3.0"
  s.homepage = "https://github.com/webema/decidim-ideas"
  s.required_ruby_version = ">= 3.0.2"

  s.name = "decidim-ideas"
  s.summary = "Decidim participatory space to collect ideas from participants"
  s.description = "Like initiatives but without signatures and promoter committee. Meant for idea collection in less formal participatory contexts."

  s.files = Dir["{app,config,db,lib,vendor}/**/*", "Rakefile", "README.md"]

  s.add_dependency "decidim-admin", Decidim::Ideas::DECIDIM_VERSION
  s.add_dependency "decidim-comments", Decidim::Ideas::DECIDIM_VERSION
  s.add_dependency "decidim-core", Decidim::Ideas::DECIDIM_VERSION
  s.add_dependency "acts_as_votable"

  s.add_dependency "wicked", "~> 1.3"

  s.add_development_dependency "decidim-dev", Decidim::Ideas::DECIDIM_VERSION
  s.add_development_dependency "decidim-meetings", Decidim::Ideas::DECIDIM_VERSION
end
