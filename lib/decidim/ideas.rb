# frozen_string_literal: true

require "decidim/ideas/admin"
require "decidim/ideas/api"
require "decidim/ideas/engine"
require "decidim/ideas/admin_engine"
require "decidim/ideas/participatory_space"

module Decidim
  # Base module for the ideas engine.
  module Ideas
    include ActiveSupport::Configurable

    # Public setting that defines whether creation is allowed to any validated
    # user or not. Defaults to true.
    config_accessor :creation_enabled do
      true
    end

    # Public Setting that defines the similarity minimum value to consider two
    # ideas similar. Defaults to 0.25.
    config_accessor :similarity_threshold do
      0.25
    end

    # Public Setting that defines how many similar ideas will be shown.
    # Defaults to 5.
    config_accessor :similarity_limit do
      5
    end

    # Components enabled for a new idea
    config_accessor :default_components do
      []
    end


    # Sets the expiration time for the statistic data.
    config_accessor :stats_cache_expiration_time do
      5.minutes
    end

    # Maximum amount of time in validating state.
    # After this time the idea will be moved to
    # discarded state.
    config_accessor :max_time_in_validating_state do
      60.days
    end

    # Print functionality enabled. Allows the user to get
    # a printed version of the idea from the administration
    # panel.
    config_accessor :print_enabled do
      true
    end

    # This flag allows creating authorizations to unauthorized users.
    config_accessor :do_not_require_authorization do
      false
    end
  end
end
