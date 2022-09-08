# frozen_string_literal: true

require "spec_helper"

describe Decidim::Ideas::AdminLog::IdeaPresenter, type: :helper do
  include_examples "present admin log entry" do
    let(:admin_log_resource) { create(:idea, organization: organization) }
    let(:action) { "publish" }
  end
end
