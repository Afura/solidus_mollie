# frozen_string_literal: true

require 'spree/core'
require 'solidus_mollie'

module SolidusMollie
  class Engine < Rails::Engine
    include SolidusSupport::EngineExtensions

    isolate_namespace ::Spree

    engine_name 'solidus_mollie'

    # use rspec for tests
    config.generators do |g|
      g.test_framework :rspec
    end
  end
end
