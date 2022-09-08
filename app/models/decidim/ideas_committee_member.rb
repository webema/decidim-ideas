# frozen_string_literal: true

# module Decidim
#   # Data store the committee members for the idea
#   class IdeasCommitteeMember < ApplicationRecord
#     belongs_to :idea,
#                foreign_key: "decidim_ideas_id",
#                class_name: "Decidim::Idea",
#                inverse_of: :committee_members

#     belongs_to :user,
#                foreign_key: "decidim_users_id",
#                class_name: "Decidim::User"

#     enum state: [:requested, :rejected, :accepted]

#     validates :state, presence: true
#     validates :user, uniqueness: { scope: :idea }

#     scope :approved, -> { where(state: :accepted) }
#     scope :non_deleted, -> { includes(:user).where(decidim_users: { deleted_at: nil }) }
#     scope :excluding_author, -> { joins(:idea).where.not("decidim_users_id = decidim_author_id") }
#   end
# end
