# frozen_string_literal: true

module Decidim
  module Ideas
    # A form object used to collect the title and description for an idea.
    class InitialDataForm < Form
      # include TranslatableAttributes
      mimic :idea

      attribute :title, String
      attribute :description, String
      attribute :problem, String
      attribute :current_state, String
      attribute :info, String

      attribute :type_id, Integer

      validates :title, :description, :problem, :current_state, :info, presence: true
      validates :title, length: { maximum: 150 }
      validates :type_id, presence: true
    end
  end
end
