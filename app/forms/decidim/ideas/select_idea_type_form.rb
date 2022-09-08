# frozen_string_literal: true

module Decidim
  module Ideas
    # A form object used to collect the idea type for an idea.
    class SelectIdeaTypeForm < Form
      mimic :idea

      attribute :type_id, Integer

      validates :type_id, presence: true
    end
  end
end
