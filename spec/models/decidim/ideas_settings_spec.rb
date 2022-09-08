# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe IdeasSettings do
    subject(:ideas_settings) { create(:ideas_settings) }

    it { is_expected.to be_valid }

    it "overwrites the log presenter" do
      expect(described_class.log_presenter_class_for(:foo))
        .to eq Decidim::Ideas::AdminLog::IdeasSettingsPresenter
    end

    context "without organization" do
      before do
        ideas_settings.organization = nil
      end

      it { is_expected.to be_invalid }
    end
  end
end
