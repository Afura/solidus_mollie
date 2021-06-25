module Spree
    class MollieController < BaseController
      skip_before_action :verify_authenticity_token, only: [:update_payment_status]
  
      # We might need this if the Webhook is late
      def validate_payment
        payment_number = split_payment_identifier(params[:order_number])
        payment = Spree::Payment.find_by(number: payment_number)
        payment.payment_method.gateway.update_payment_status(payment)

        order = payment.order
        order.reload

        binding.pry
  
        # Order is paid for or authorized (e.g. Klarna Pay Later)
        if (order.paid? && (order.can_complete?))
          order.complete

          redirect_to "https://bitter-lizard-32.loca.lt/checkout/success/#{order.number}"
          # redirect_to order_path(payment.order)
        else payment.pending?
          redirect_to "https://bitter-lizard-32.loca.ltcheckout/#{params[:order_number]}"
          # redirect_to checkout_state_path(:payment)
        end
      end
 
     # Mollie might send us information about a transaction through the webhook.
     # We should update the payment state accordingly.
     def update_payment_status
      payment_number = split_payment_identifier(params[:payment_identifier])
      payment = Spree::Payment.find_by(number: payment_number)
      payment.payment_method.gateway.update_payment_status(payment)
  
      head :ok
     end
 
     private
 
     # Payment identifier is a combination of order_number and payment_id.
     def split_payment_identifier(payment_identifier)
        payment_identifier.split('-')[1]
     end

     def payment_status_params
      params.permit(:payment_identifier, :id)
    end

      def load_order
        @order = ::Spree::Order.find_by!(number: params[:order_id])
      end
   end
 end