module SolidusMollie
  module PaymentCreateDecorator
  
    def authorized?
      if source.is_a? Spree::MolliePaymentSource
        pending?
      else
        false
      end
    end
  
    def after_pay_method?
      if source.is_a? Spree::MolliePaymentSource
        return source.payment_method_name == ::Mollie::Method::KLARNAPAYLATER || source.payment_method_name == ::Mollie::Method::KLARNASLICEIT
      else
        false
      end
    end

    ::Spree::PaymentCreate.prepend self
  end
 end