# frozen_string_literal: true

module Decidim
  module Ideas
    module Admin
      # A form object used to create ideas settings from the admin dashboard.
      class IdeasSettingsForm < Form
        mimic :ideas_settings

        attribute :ideas_order, String
      end
    end
  end
end
