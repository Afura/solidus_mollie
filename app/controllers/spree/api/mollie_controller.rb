module Spree
   module Api
      class MollieController < Spree::Api::BaseController
         def payment_methods
            #FIXME: This is not safe. 
            order = Spree::Order.find_by(number: params[:id])
            method_params = payload(order)

            payment_methods = Spree::PaymentMethod::Mollie.first.gateway.available_methods(method_params).map(&:attributes)

            render json: payment_methods
         end

         def validate_payment
         end

         private

         def payload(order)
            {
               amount: {
                  currency: order.currency,
                  value: Spree::Money.new(order.order_total_after_store_credit, { symbol: nil, thousands_separator: nil, decimal_mark: '.' }).format
               },
               resource: 'orders',
               billingCountry: order.bill_address.country.iso
            }
         end
      end
   end
 end