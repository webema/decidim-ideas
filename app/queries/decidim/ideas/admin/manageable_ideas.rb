# frozen_string_literal: true

module Decidim
  module Ideas
    module Admin
      # Class that retrieves manageable ideas for the given user.
      # Regular users will get only their ideas. Administrators will
      # retrieve all ideas.
      class ManageableIdeas < Decidim::Query
        # Syntactic sugar to initialize the class and return the queried objects
        #
        # user - Decidim::User
        def self.for(user)
          new(user).query
        end

        # Initializes the class.
        #
        # user - Decidim::User
        def initialize(user)
          @user = user
        end

        # Retrieves all ideas / Ideas created by the user.
        def query
          return Idea.where(organization: @user.organization) if @user.admin?

          Idea.where(id: IdeasCreated.by(@user) + IdeasPromoted.by(@user))
        end
      end
    end
  end
end
