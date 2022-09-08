# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Ideas
    module Admin
      describe CreateIdeaTypeScope do
        let(:form_klass) { IdeaTypeScopeForm }

        describe "Successfull creation" do
          it_behaves_like "create an idea type scope"
        end

        describe "Attempt of creating duplicated typed scopes" do
          let(:organization) { create(:organization) }
          let(:idea_type) { create(:ideas_type, organization: organization) }
          let!(:idea_type_scope) do
            create(:ideas_type_scope, type: idea_type)
          end
          let(:form) do
            form_klass
              .from_model(idea_type_scope)
              .with_context(type_id: idea_type.id, current_organization: organization)
          end
          let(:command) { described_class.new(form) }

          it "broadcasts invalid" do
            expect { command.call }.to broadcast :invalid
          end
        end
      end
    end
  end
end
