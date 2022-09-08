# frozen_string_literal: true

module Decidim
  module Ideas
    module Admin
      # A form object used to collect the all the scopes related to an
      # idea type
      class IdeaTypeScopeForm < Form
        mimic :ideas_type_scope

        attribute :decidim_scopes_id, Integer
      end
    end
  end
end
