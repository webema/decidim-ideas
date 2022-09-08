# frozen_string_literal: true

require "spec_helper"
require "decidim/api/test/type_context"
require "decidim/ideas/test/factories"

describe "Decidim::Api::QueryType" do
  include_context "with a graphql class type"
  let(:schema) { Decidim::Api::Schema }

  let(:locale) { "en" }
  let!(:idea) { create(:idea, organization: current_organization) }

  let(:idea_data) do
    {
      "attachments" => [],
      "author" => { "id" => idea.author.id.to_s },
      "committeeMembers" => idea.committee_members.map do |cm|
        {
          "createdAt" => cm.created_at.iso8601.to_s.gsub("Z", "+00:00"),
          "id" => cm.id.to_s,
          "state" => cm.state,
          "updatedAt" => cm.updated_at.iso8601.to_s.gsub("Z", "+00:00"),
          "user" => { "id" => cm.decidim_users_id.to_s }
        }
      end,
      "components" => [],
      "createdAt" => idea.created_at.iso8601.to_s.gsub("Z", "+00:00"),
      "description" => { "translation" => idea.description[locale] },
      "hashtag" => idea.hashtag,
      "id" => idea.id.to_s,
      "ideaType" => {
        "bannerImage" => idea.type.attached_uploader(:banner_image).path,
        "collectUserExtraFields" => idea.type.collect_user_extra_fields?,
        "createdAt" => idea.type.created_at.iso8601.to_s.gsub("Z", "+00:00"),
        "description" => { "translation" => idea.type.description[locale] },
        "extraFieldsLegalInformation" => idea.type.extra_fields_legal_information,
        "id" => idea.type.id.to_s,
        "ideas" => idea.type.ideas.map { |i| { "id" => i.id.to_s } },
        "minimumCommitteeMembers" => idea.type.minimum_committee_members,
        "promotingComitteeEnabled" => idea.type.promoting_committee_enabled,
        "signatureType" => idea.type.signature_type,
        "title" => { "translation" => idea.type.title[locale] },
        "undoOnlineSignaturesEnabled" => idea.type.undo_online_signatures_enabled,
        "updatedAt" => idea.type.updated_at.iso8601.to_s.gsub("Z", "+00:00"),
        "validateSmsCodeOnVotes" => idea.type.validate_sms_code_on_votes
      },
      "offlineVotes" => idea.offline_votes_count,
      "onlineVotes" => idea.online_votes_count,
      "publishedAt" => idea.published_at.iso8601.to_s.gsub("Z", "+00:00"),
      "reference" => idea.reference,
      "scope" => { "id" => idea.scope.id.to_s },
      "signatureEndDate" => idea.signature_end_date.to_date.to_s,
      "signatureStartDate" => idea.signature_start_date.to_date.to_s,
      "signatureType" => idea.signature_type,
      "slug" => idea.slug,
      "state" => idea.state,
      "title" => { "translation" => idea.title[locale] },
      "type" => idea.class.name,
      "updatedAt" => idea.updated_at.iso8601.to_s.gsub("Z", "+00:00")

    }
  end

  let(:ideas) do
    %(
      ideas{
        attachments {
          thumbnail
        }
        author {
          id
        }
        committeeMembers {
          createdAt
          id
          state
          updatedAt
          user { id }
        }
        components {
          id
        }
        createdAt
        description {
          translation(locale: "#{locale}")
        }
        hashtag
        id
        ideaType {
          bannerImage
          collectUserExtraFields
          createdAt
          description {
          translation(locale: "#{locale}")
          }
          extraFieldsLegalInformation
          id
          ideas{id}
          minimumCommitteeMembers
          promotingComitteeEnabled
          signatureType
          title {
                  translation(locale: "#{locale}")

          }
          undoOnlineSignaturesEnabled
          updatedAt
          validateSmsCodeOnVotes
        }
        offlineVotes
        onlineVotes
        publishedAt
        reference
        scope {
          id
        }
        signatureEndDate
        signatureStartDate
        signatureType
        slug
        state
        title {
          translation(locale: "#{locale}")
        }
        type
        updatedAt
      }
    )
  end

  let(:query) do
    %(
      query {
        #{ideas}
      }
    )
  end

  describe "valid query" do
    it "executes sucessfully" do
      expect { response }.not_to raise_error
    end

    it "returns the correct response" do
      expect(response["ideas"].first).to eq(idea_data)
    end

    it_behaves_like "implements stats type" do
      let(:ideas) do
        %(
          ideas {
            stats{
              name
              value
            }
          }
        )
      end
      let(:stats_response) { response["ideas"].first["stats"] }
    end
  end

  describe "single assembly" do
    let(:ideas) do
      %(
      idea(id: #{idea.id}){
        attachments {
          thumbnail
        }
        author {
          id
        }
        committeeMembers {
          createdAt
          id
          state
          updatedAt
          user { id }
        }
        components {
          id
        }
        createdAt
        description {
          translation(locale: "en")
        }
        hashtag
        id
        ideaType {
          bannerImage
          collectUserExtraFields
          createdAt
          description {
          translation(locale: "en")
          }
          extraFieldsLegalInformation
          id
          ideas{id}
          minimumCommitteeMembers
          promotingComitteeEnabled
          signatureType
          title {
                  translation(locale: "en")

          }
          undoOnlineSignaturesEnabled
          updatedAt
          validateSmsCodeOnVotes
        }
        offlineVotes
        onlineVotes
        publishedAt
        reference
        scope {
          id
        }
        signatureEndDate
        signatureStartDate
        signatureType
        slug
        state
        title {
          translation(locale: "en")
        }
        type
        updatedAt
      }
    )
    end

    it "executes sucessfully" do
      expect { response }.not_to raise_error
    end

    it "returns the correct response" do
      expect(response["idea"]).to eq(idea_data)
    end

    it_behaves_like "implements stats type" do
      let(:ideas) do
        %(
          idea(id: #{idea.id}){
            stats{
              name
              value
            }
          }
        )
      end
      let(:stats_response) { response["idea"]["stats"] }
    end
  end
end
