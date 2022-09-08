# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Ideas
    describe CreateIdeaHelper do
      let(:online) { %w(Online online) }
      let(:offline) { ["In-person", "offline"] }
      let(:mixed) { %w(Mixed any) }
      let(:all) { [online, offline, mixed] }

      let(:organization) { create(:organization) }
      let(:idea_type) { create(:ideas_type, signature_type: signature_type, organization: organization) }
      let(:scope) { create(:ideas_type_scope, type: idea_type) }
      let(:idea_state) { "created" }
      let(:idea) { create(:idea, organization: organization, scoped_type: scope, signature_type: signature_type, state: idea_state) }

      let(:form_klass) { ::Decidim::Ideas::Admin::IdeaForm }
      let(:form) do
        form_klass.from_params(
          form_params
        ).with_context(
          current_organization: organization,
          idea: idea
        )
      end
      let(:form_params) do
        {
          type_id: idea_type.id,
          decidim_scope_id: scope.id,
          state: idea_state
        }
      end
      let(:options) do
        helper.signature_type_options(form)
      end

      context "when any signature enabled" do
        let(:signature_type) { "any" }

        it "contains online and offline signature type options" do
          expect(options).to match_array(all)
        end
      end

      context "when online signature disabled" do
        let(:signature_type) { "offline" }

        it "contains offline signature type options" do
          expect(options).not_to include(online)
          expect(options).not_to include(mixed)
          expect(options).to include(offline)
        end
      end

      context "when online signature enabled" do
        let(:signature_type) { "online" }

        it "contains all signature type options" do
          expect(options).to include(online)
          expect(options).not_to include(mixed)
          expect(options).not_to include(offline)
        end
      end
    end
  end
end
