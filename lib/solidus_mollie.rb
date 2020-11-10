# frozen_string_literal: true

require 'solidus_core'
require 'solidus_support'

require 'solidus_mollie/configuration'
require 'solidus_mollie/version'
require 'solidus_mollie/engine'

module SolidusMollie
  class << self
    def configuration
      @configuration ||= Configuration.new
    end

    def configure
      yield configuration
    end
  end
end
