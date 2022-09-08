# frozen_string_literal: true

require "spec_helper"

describe Decidim::Ideas::Engine do
  it "loads engine mailer previews" do
    expect(ActionMailer::Preview.all).to include(Decidim::Ideas::IdeasMailerPreview)
  end
end
