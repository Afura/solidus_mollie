
# frozen_string_literal: true

module SolidusMollie
  class PaymentMethod < SolidusSupport.payment_method_parent_class
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