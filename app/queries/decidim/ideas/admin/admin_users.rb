# frozen_string_literal: true

module Decidim
  module Ideas
    module Admin
      # A class used to find the admins for an idea or an organization ideas.
      class AdminUsers < Decidim::Query
        # Syntactic sugar to initialize the class and return the queried objects.
        #
        # idea - Decidim::Idea
        def self.for(idea)
          new(idea).query
        end

        # Syntactic sugar to initialize the class and return the queried objects.
        #
        # organization - an organization that needs to find its idea admins
        def self.for_organization(organization)
          new(nil, organization).query
        end

        # Initializes the class.
        #
        # idea - Decidim::Idea
        # organization - an organization that needs to find its idea admins
        def initialize(idea, organization = nil)
          @idea = idea
          @organization = idea&.organization || organization
        end

        # Finds organization admins and the users with role admin for the given idea.
        #
        # Returns an ActiveRecord::Relation.
        def query
          organization.admins
        end

        private

        attr_reader :idea, :organization
      end
    end
  end
end
