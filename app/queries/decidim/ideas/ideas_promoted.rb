# frozen_string_literal: true
# TODO delete?

# module Decidim
#   module Ideas
#     # Class uses to retrieve ideas promoted by the given  user
#     class IdeasPromoted < Decidim::Query
#       attr_reader :user

#       # Syntactic sugar to initialize the class and return the queried objects.
#       #
#       # user - Decidim::User
#       def self.by(user)
#         new(user).query
#       end

#       # Initializes the class.
#       #
#       # user: Decidim::User
#       def initialize(user)
#         @user = user
#       end

#       # Retrieves the ideas promoted by the  given  user.
#       def query
#         Idea
#           .joins(:committee_members)
#           .where("decidim_ideas_committee_members.state = 2")
#           .where(decidim_ideas_committee_members: { decidim_users_id: user.id })
#       end
#     end
#   end
# end
