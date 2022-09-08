# frozen_string_literal: true

require "spec_helper"

describe Decidim::IdeasVotes::VoteCell, type: :cell do
  subject { cell("decidim/ideas_votes/vote", vote).call }

  controller Decidim::PagesController

  let(:vote) do
    create(:idea_user_vote,
           idea: create(:idea, :with_user_extra_fields_collection),
           encrypted_metadata: Decidim::Ideas::DataEncryptor.new(secret: "personal user metadata").encrypt(personal_data_params))
  end

  let(:personal_data_params) do
    {
      name_and_surname: ::Faker::Name.name,
      document_number: ::Faker::IDNumber.spanish_citizen_number,
      date_of_birth: ::Faker::Date.birthday(min_age: 18, max_age: 40),
      postal_code: ::Faker::Address.zip_code
    }
  end

  context "when rendering" do
    it "shows title and identifier of idea" do
      expect(subject).to have_content(vote.idea.title[:en])
      expect(subject).to have_content(translated(vote.idea.title, locale: :en))
    end

    it "shows decrypted data" do
      expect(subject).to have_content(personal_data_params[:name_and_surname])
      expect(subject).to have_content(personal_data_params[:document_number])
      expect(subject).to have_content(personal_data_params[:date_of_birth])
      expect(subject).to have_content(personal_data_params[:postal_code])
    end
  end
end
