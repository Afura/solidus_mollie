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

    Spree::PermittedAttributes.source_attributes << :payment_method_id

    initializer "register_spree_mollie_payment_method", after: "spree.register.payment_methods" do |app|
      app.config.spree.payment_methods << SolidusMollie::PaymentMethod
    end
  end
end
