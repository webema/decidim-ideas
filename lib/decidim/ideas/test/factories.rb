# frozen_string_literal: true

require "decidim/faker/localized"
require "decidim/dev"

FactoryBot.define do
  factory :ideas_type, class: "Decidim::IdeasType" do
    title { generate_localized_title }
    description { Decidim::Faker::Localized.wrapped("<p>", "</p>") { generate_localized_title } }
    organization
    # Keep banner_image after organization
    banner_image do
      ActiveStorage::Blob.create_and_upload!(
        io: File.open(Decidim::Dev.test_file("city2.jpeg", "image/jpeg")),
        filename: "city2.jpeg",
        content_type: "image/jpeg"
      ).signed_id
    end
    signature_type { :online }
    attachments_enabled { true }
    undo_online_signatures_enabled { true }
    custom_signature_end_date_enabled { false }
    area_enabled { false }
    promoting_committee_enabled { true }
    minimum_committee_members { 3 }
    child_scope_threshold_enabled { false }
    only_global_scope_enabled { false }
    comments_enabled { true }

    trait :with_comments_disabled do
      comments_enabled { false }
    end

    trait :attachments_enabled do
      attachments_enabled { true }
    end

    trait :attachments_disabled do
      attachments_enabled { false }
    end

    trait :online_signature_enabled do
      signature_type { :online }
    end

    trait :online_signature_disabled do
      signature_type { :offline }
    end

    trait :undo_online_signatures_enabled do
      undo_online_signatures_enabled { true }
    end

    trait :undo_online_signatures_disabled do
      undo_online_signatures_enabled { false }
    end

    trait :custom_signature_end_date_enabled do
      custom_signature_end_date_enabled { true }
    end

    trait :custom_signature_end_date_disabled do
      custom_signature_end_date_enabled { false }
    end

    trait :area_enabled do
      area_enabled { true }
    end

    trait :area_disabled do
      area_enabled { false }
    end

    trait :promoting_committee_enabled do
      promoting_committee_enabled { true }
    end

    trait :promoting_committee_disabled do
      promoting_committee_enabled { false }
      minimum_committee_members { 0 }
    end

    trait :with_user_extra_fields_collection do
      collect_user_extra_fields { true }
      extra_fields_legal_information { Decidim::Faker::Localized.wrapped("<p>", "</p>") { generate_localized_title } }
      document_number_authorization_handler { "dummy_authorization_handler" }
    end

    trait :with_sms_code_validation do
      validate_sms_code_on_votes { true }
    end

    trait :child_scope_threshold_enabled do
      child_scope_threshold_enabled { true }
    end

    trait :only_global_scope_enabled do
      only_global_scope_enabled { true }
    end
  end

  factory :ideas_type_scope, class: "Decidim::IdeasTypeScope" do
    type { create(:ideas_type) }
    scope { create(:scope, organization: type.organization) }
    supports_required { 1000 }

    trait :with_user_extra_fields_collection do
      type { create(:ideas_type, :with_user_extra_fields_collection) }
    end
  end

  factory :idea, class: "Decidim::Idea" do
    title { generate_localized_title }
    description { Decidim::Faker::Localized.wrapped("<p>", "</p>") { generate_localized_title } }
    organization
    author { create(:user, :confirmed, organization: organization) }
    published_at { Time.current }
    state { "published" }
    signature_type { "online" }
    signature_start_date { Date.current - 1.day }
    signature_end_date { Date.current + 120.days }

    scoped_type do
      create(:ideas_type_scope,
             type: create(:ideas_type, organization: organization, signature_type: signature_type))
    end

    after(:create) do |idea|
      if idea.author.is_a?(Decidim::User) && Decidim::Authorization.where(user: idea.author).where.not(granted_at: nil).none?
        create(:authorization, user: idea.author, granted_at: Time.now.utc)
      end
      create_list(:ideas_committee_member, 3, idea: idea)
    end

    trait :created do
      state { "created" }
      published_at { nil }
      signature_start_date { nil }
      signature_end_date { nil }
    end

    trait :validating do
      state { "validating" }
      published_at { nil }
      signature_start_date { nil }
      signature_end_date { nil }
    end

    trait :published do
      state { "published" }
    end

    trait :unpublished do
      published_at { nil }
    end

    trait :accepted do
      state { "accepted" }
    end

    trait :discarded do
      state { "discarded" }
    end

    trait :rejected do
      state { "rejected" }
    end

    trait :online do
      signature_type { "online" }
    end

    trait :offline do
      signature_type { "offline" }
    end

    trait :acceptable do
      signature_start_date { Date.current - 3.months }
      signature_end_date { Date.current - 2.months }
      signature_type { "online" }

      after(:build) do |idea|
        idea.online_votes[idea.scope.id.to_s] = idea.supports_required + 1
        idea.online_votes["total"] = idea.supports_required + 1
      end
    end

    trait :rejectable do
      signature_start_date { Date.current - 3.months }
      signature_end_date { Date.current - 2.months }
      signature_type { "online" }

      after(:build) do |idea|
        idea.online_votes[idea.scope.id.to_s] = 0
        idea.online_votes["total"] = 0
      end
    end

    trait :with_user_extra_fields_collection do
      scoped_type do
        create(:ideas_type_scope,
               type: create(:ideas_type, :with_user_extra_fields_collection, organization: organization))
      end
    end

    trait :with_area do
      area { create(:area, organization: organization) }
    end

    trait :with_documents do
      transient do
        documents_number { 2 }
      end

      after :create do |idea, evaluator|
        evaluator.documents_number.times do
          idea.attachments << create(
            :attachment,
            :with_pdf,
            attached_to: idea
          )
        end
      end
    end

    trait :with_photos do
      transient do
        photos_number { 2 }
      end

      after :create do |idea, evaluator|
        evaluator.photos_number.times do
          idea.attachments << create(
            :attachment,
            :with_image,
            attached_to: idea
          )
        end
      end
    end
  end

  factory :idea_user_vote, class: "Decidim::IdeasVote" do
    idea { create(:idea) }
    author { create(:user, :confirmed, organization: idea.organization) }
    hash_id { SecureRandom.uuid }
    scope { idea.scope }
    after(:create) do |vote|
      vote.idea.update_online_votes_counters
    end
  end

  factory :organization_user_vote, class: "Decidim::IdeasVote" do
    idea { create(:idea) }
    author { create(:user, :confirmed, organization: idea.organization) }
    decidim_user_group_id { create(:user_group).id }
    after(:create) do |support|
      create(:user_group_membership, user: support.author, user_group: Decidim::UserGroup.find(support.decidim_user_group_id))
    end
  end

  factory :ideas_committee_member, class: "Decidim::IdeasCommitteeMember" do
    idea { create(:idea) }
    user { create(:user, :confirmed, organization: idea.organization) }
    state { "accepted" }

    trait :accepted do
      state { "accepted" }
    end

    trait :requested do
      state { "requested" }
    end

    trait :rejected do
      state { "rejected" }
    end
  end

  factory :ideas_settings, class: "Decidim::IdeasSettings" do
    ideas_order { "random" }
    organization

    trait :most_recent do
      ideas_order { "date" }
    end

    trait :most_signed do
      ideas_order { "signatures" }
    end

    trait :most_commented do
      ideas_order { "comments" }
    end

    trait :most_recently_published do
      ideas_order { "publication_date" }
    end
  end
end
