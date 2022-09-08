# frozen_string_literal: true

require "spec_helper"

describe "Idea embeds", type: :system do
  let(:resource) { create(:idea) }

  it_behaves_like "an embed resource", skip_space_checks: true
end
