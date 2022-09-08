# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Ideas
    module Admin
      describe UpdateIdeaTypeScope do
        let(:form_klass) { IdeaTypeScopeForm }

        context "when successfull update" do
          it_behaves_like "update an idea type scope"
        end
      end
    end
  end
end
