module Spree
    class MollieController < BaseController
      skip_before_action :verify_authenticity_token, only: [:update_payment_status]
  
      # When the user is redirected from Mollie back to the shop, we can check the
      # mollie transaction status and set the Spree order state accordingly.
      def validate_payment
        payment_number = split_payment_identifier params[:order_number]

        payment = Spree::Payment.find_by_number(payment_number)

        payment.payment_method.gateway.update_payment_status(payment)
        payment.order.reload
  
        # Order is paid for or authorized (e.g. Klarna Pay Later)
        if (order.paid? ||)
          redirect_to order_path(order)
        else payment.pending? && payment.pending?
          redirect_to checkout_state_path(:payment)
        end
      end
 
     # Mollie might send us information about a transaction through the webhook.
     # We should update the payment state accordingly.
     def update_payment_status
        # payment_number = split_payment_identifier(params[:order_number])

        payment_number = split_payment_identifier('R715400817-YWGXP9ZP')
        payment = Spree::Payment.find_by(number: payment_number)
        payment.payment_method.gateway.update_payment_status(payment)
  
        head :ok
     end
 
     private
 
     # Payment identifier is a combination of order_number and payment_id.
     def split_payment_identifier(payment_identifier)
        payment_identifier.split('-')[1]
     end
   end
 end