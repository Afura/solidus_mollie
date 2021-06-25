module Spree
   class MolliePaymentSource < Spree::PaymentSource

     self.table_name = "solidus_mollie_payment_sources"
 
     def transaction_id 
       payment_id
     end
 
     def method_type
       'mollie_payment_source'
     end

     def name
      case payment_method_name
      when ::Mollie::Method::IDEAL then
        'iDEAL'
      when ::Mollie::Method::CREDITCARD then
        'Credit card'
      when ::Mollie::Method::BANCONTACT then
        'Bancontact'
      when ::Mollie::Method::SOFORT then
        'SOFORT Banking'
      when ::Mollie::Method::BANKTRANSFER then
        'Bank transfer'
      when ::Mollie::Method::PAYPAL then
        'PayPal'
      when ::Mollie::Method::KBC then
        'KBC/CBC Payment Button'
      when ::Mollie::Method::BELFIUS then
        'Belfius Pay Button'
      when ::Mollie::Method::PAYSAFECARD then
        'paysafecard'
      when ::Mollie::Method::GIFTCARD then
        'Giftcard'
      when ::Mollie::Method::INGHOMEPAY then
        'ING Home\'Pay'
      when ::Mollie::Method::EPS then
        'EPS'
      when ::Mollie::Method::GIROPAY then
        'Giropay'
      when ::Mollie::Method::DIRECTDEBIT then
        'SEPA Direct debit'
      when ::Mollie::Method::KLARNASLICEIT then
        'Klarna Slice it'
      when ::Mollie::Method::KLARNAPAYLATER then
        'Klarna Pay Later'
      when ::Mollie::Method::PRZELEWY24 then
        'Przelewy24'
      when ::Mollie::Method::APPLEPAY then
        'Apple Pay'
      # As of May 1st 2019, Bitcoin is no longer supported.
      when 'bitcoin' then
        'Bitcoin'
      else
        'Mollie (Unknown method)'
      end
    end
    
   end
 end