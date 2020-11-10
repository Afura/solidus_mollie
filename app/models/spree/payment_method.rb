
# frozen_string_literal: true

module SolidusMollie
   class PaymentMethod < Spree::PaymentMethod
     preference :api_key, :string
   end
 end