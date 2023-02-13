# frozen_string_literal: true

module Decidim
  # The data store for a Idea in the Decidim::Ideas component.
  class Idea < ApplicationRecord
    include ActiveModel::Dirty
    include Decidim::Authorable
    include Decidim::Participable
    include Decidim::Publicable
    include Decidim::ScopableParticipatorySpace
    include Decidim::Comments::Commentable
    include Decidim::Followable
    include Decidim::HasAttachments
    include Decidim::HasAttachmentCollections
    include Decidim::HasUploadValidations
    include Decidim::Traceable
    include Decidim::Loggable
    include Decidim::Ideas::IdeaSlug
    include Decidim::Resourceable
    include Decidim::HasReference
    include Decidim::Randomable
    include Decidim::Searchable
    include Decidim::Ideas::HasArea
    include Decidim::TranslatableResource
    include Decidim::HasResourcePermission
    include Decidim::HasArea
    include Decidim::FilterableResource

    require "acts_as_votable"
    acts_as_votable cacheable_strategy: :update_columns

    translatable_fields :title, :description, :answer

    belongs_to :organization,
               foreign_key: "decidim_organization_id",
               class_name: "Decidim::Organization"

    belongs_to :scoped_type,
               class_name: "Decidim::IdeasTypeScope",
               inverse_of: :ideas

    delegate :type, :scope, :scope_name, :supports_required, to: :scoped_type, allow_nil: true
    delegate :attachments_enabled?, to: :type
    delegate :name, to: :area, prefix: true, allow_nil: true

    has_many :votes,
             foreign_key: "decidim_idea_id",
             class_name: "Decidim::IdeasVote",
             dependent: :destroy,
             inverse_of: :idea

    has_many :components, as: :participatory_space, dependent: :destroy

    # This relationship exists only by compatibility reasons.
    # Ideas are not intended to have categories.
    has_many :categories,
             foreign_key: "decidim_participatory_space_id",
             foreign_type: "decidim_participatory_space_type",
             dependent: :destroy,
             as: :participatory_space

    has_one_attached :hero_image
    validates_upload :hero_image, uploader: Decidim::HeroImageUploader

    enum state: [:created, :validating, :discarded, :published, :rejected, :forwarded, :assemblified, :processified, :pilotified]

    validates :title, :description, :state, presence: true
    validates :hashtag, uniqueness: { allow_blank: true, case_sensitive: false }
    validates :answer_url, url: { allow_blank: true }

    scope :open, lambda {
      where(state: [:validating, :published])
    }
    scope :closed, lambda {
      where(state: [:discarded, :rejected, :forwarded, :assemblified, :processified, pilotified])
    }
    scope :published, -> { where.not(published_at: nil) }
    scope :with_state, ->(state) { where(state: state) if state.present? }

    scope_search_multi :with_any_state, [:open, :validating, :published, :rejected, :forwarded, :assemblified, :processified, :pilotified]

    scope :answered, -> { where.not(answered_at: nil) }

    scope :public_spaces, -> { published }

    scope :order_by_most_recent, -> { order(created_at: :desc) }
    scope :order_by_most_recently_published, -> { order(published_at: :desc) }
    scope :order_by_most_commented, lambda {
      select("decidim_ideas.*")
        .left_joins(:comments)
        .group("decidim_ideas.id")
        .order(Arel.sql("count(decidim_comments_comments.id) desc"))
    }
    scope :order_by_most_voted, lambda {
      order('cached_votes_up desc')
    }
    scope :future_spaces, -> { none }
    scope :past_spaces, -> { closed }

    scope :with_any_type, lambda { |*original_type_ids|
      type_ids = original_type_ids.flatten
      return self if type_ids.include?("all")

      types = IdeasTypeScope.where(decidim_ideas_types_id: type_ids).pluck(:id)
      where(scoped_type: types)
    }

    # Redefine the with_any_scope method as the idea scope is defined by
    # the idea type scope.
    scope :with_any_scope, lambda { |*original_scope_ids|
      scope_ids = original_scope_ids.flatten
      return self if scope_ids.include?("all")

      clean_scope_ids = scope_ids

      conditions = []
      conditions << "decidim_ideas_type_scopes.decidim_scopes_id IS NULL" if clean_scope_ids.delete("global")
      conditions.concat(["? = ANY(decidim_scopes.part_of)"] * clean_scope_ids.count) if clean_scope_ids.any?

      joins(:scoped_type).references(:decidim_scopes).where(conditions.join(" OR "), *clean_scope_ids.map(&:to_i))
    }

    scope :authored_by, lambda { |author|
      where(
        decidim_author_id: author,
        decidim_author_type: Decidim::UserBaseEntity.name
      )
    }

    after_commit :notify_state_change
    after_create :notify_creation

    searchable_fields({
                        participatory_space: :itself,
                        A: :title,
                        D: :description,
                        datetime: :published_at
                      },
                      index_on_create: ->(_idea) { false },
                      # is Resourceable instead of ParticipatorySpaceResourceable so we can't use `visible?`
                      index_on_update: ->(idea) { idea.published? })

    def self.log_presenter_class_for(_log)
      Decidim::Ideas::AdminLog::IdeaPresenter
    end

    def self.ransackable_scopes(_auth_object = nil)
      [:with_any_state, :with_any_type, :with_any_scope, :with_any_area]
    end

    delegate :type, :scope, :scope_name, to: :scoped_type, allow_nil: true

    # Public: Overrides participatory space's banner image with the banner image defined
    # for the idea type.
    #
    # Returns Decidim::BannerImageUploader
    def banner_image
      type.attached_uploader(:banner_image)
    end

    # Public: Whether the object's comments are visible or not.
    def commentable?
      type.comments_enabled?
    end

    # Public: Check if an idea has been created by an individual person.
    # If it's false, then it has been created by an authorized organization.
    #
    # Returns a Boolean
    def created_by_individual?
      decidim_user_group_id.nil?
    end

    # Public: check if an idea is open
    #
    # Returns a Boolean
    def open?
      !closed?
    end

    # Public: Checks if an idea is closed. An idea is closed when
    # at least one of the following conditions is true:
    #
    # * It has been discarded.
    # * It has been rejected.
    # * It has been accepted.
    # * Signature collection period has finished.
    #
    # Returns a Boolean
    def closed?
      discarded? || rejected? || forwarded? || assemblified? || processified? || pilotified?
    end

    # Public: Returns the author name. If it has been created by an organization it will
    # return the organization's name. Otherwise it will return author's name.
    #
    # Returns a string
    def author_name
      user_group&.name || author.name
    end

    # Public: Check if the user has voted the question.
    #
    # Returns Boolean.
    def voted_by?(user)
      votes.where(author: user).any?
    end

    # Public: Checks if the organization has given an answer for the idea.
    #
    # Returns a Boolean.
    def answered?
      answered_at.present?
    end

    def accepted?
      forwarded? || assemblified? || processified? || pilotified?
    end

    # Public: Overrides scopes enabled flag available in other models like
    # participatory space or assemblies. For ideas it won't be directly
    # managed by the user and it will be enabled by default.
    def scopes_enabled?
      true
    end

    # Public: Overrides scopes enabled attribute value.
    # For ideas it won't be directly
    # managed by the user and it will be enabled by default.
    def scopes_enabled
      true
    end

    # Public: Publishes this idea
    #
    # Returns true if the record was properly saved, false otherwise.
    def publish!
      return false if published?

      update(
        published_at: Time.current,
        state: "published",
        # signature_start_date: Date.current,
        # signature_end_date: signature_end_date || (Date.current + Decidim::Ideas.default_signature_time_period_length)
      )
    end

    # Public: Unpublishes this idea
    #
    # Returns true if the record was properly saved, false otherwise.
    def unpublish!
      return false unless published?

      update(published_at: nil, state: "discarded")
    end

    # Public: Returns the hashtag for the idea.
    def hashtag
      attributes["hashtag"].to_s.delete("#")
    end

    # Public: Overrides slug attribute from participatory processes.
    def slug
      slug_from_id(id)
    end

    def to_param
      slug
    end

    # Public: Overrides the `comments_have_alignment?`
    # Commentable concern method.
    def comments_have_alignment?
      true
    end

    # Public: Overrides the `comments_have_votes?` Commentable concern method.
    def comments_have_votes?
      true
    end

    # Public:  Checks if user is the author or is part of the promotal committee
    # of the idea.
    #
    # Returns a Boolean.
    def has_authorship?(user)
      author.id == user.id
    end

    def author_users
      [author] # .concat(committee_members.excluding_author.map(&:user))
    end

    def component
      nil
    end

    # Public: Checks if the type the idea belongs to enables SMS code
    # verification step. Tis configuration is ignored if the organization
    # doesn't have the sms authorization available
    #
    # Returns a Boolean
    def validate_sms_code_on_votes?
      organization.available_authorizations.include?("sms") && type.validate_sms_code_on_votes?
    end

    # Public: Returns an empty object. This method should be implemented by
    # `ParticipatorySpaceResourceable`, but for some reason this model does not
    # implement this interface.
    def user_role_config_for(_user, _role_name)
      Decidim::ParticipatorySpaceRoleConfig::Base.new(:empty_role_name)
    end

    # Public: Overrides the `allow_resource_permissions?` Resourceable concern method.
    def allow_resource_permissions?
      true
    end

    def user_allowed_to_comment?(user)
      ActionAuthorizer.new(user, "comment", self, nil).authorize.ok?
    end

    def self.ransack(params = {}, options = {})
      Ideas::IdeaSearch.new(self, params, options)
    end

    # Public: Override Commentable concern method `users_to_notify_on_comment_created`
    def users_to_notify_on_comment_created
      followers
    end

    private

    # Private: This is just an alias because the naming on IdeaTypeScope
    # is very confusing. The `scopes` method doesn't return Decidim::Scope but
    # Decidim::IdeaTypeScopes.
    #
    # ¯\_(ツ)_/¯
    #
    # Returns an Array of Decidim::IdeasScopeType.
    def idea_type_scopes
      type.scopes
    end

    def notify_state_change
      return unless saved_change_to_state?

      notifier = Decidim::Ideas::StatusChangeNotifier.new(idea: self)
      notifier.notify
    end

    def notify_creation
      notifier = Decidim::Ideas::StatusChangeNotifier.new(idea: self)
      notifier.notify
    end

    # Allow ransacker to search for a key in a hstore column (`title`.`en`)
    [:title, :description].each { |column| ransacker_i18n(column) }

    # Alias search_text as a grouped OR query with all the text searchable fields.
    ransack_alias :search_text, :id_string_or_title_or_description_or_author_name_or_author_nickname

    # Allow ransacker to search on an Enum Field
    ransacker :state, formatter: proc { |int| states[int] }

    ransacker :type_id do
      Arel.sql("decidim_ideas_type_scopes.decidim_ideas_types_id")
    end

    ransacker :id_string do
      Arel.sql(%{cast("decidim_ideas"."id" as text)})
    end

    ransacker :author_name do
      Arel.sql("decidim_users.name")
    end

    ransacker :author_nickname do
      Arel.sql("decidim_users.nickname")
    end
  end
end
