
# frozen_string_literal: true

module Spree
  class PaymentMethod::Mollie < Spree::PaymentMethod
    preference :api_key, :string

    def payment_source_class
      MolliePaymentSource
    end

    def partial_name
      "mollie"
    end

    def auto_capture
      false
    end

    protected

    def gateway_class
      Spree::Gateway::MollieGateway
    end
  end
end