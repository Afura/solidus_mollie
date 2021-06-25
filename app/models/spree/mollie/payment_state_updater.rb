module Spree
   module Mollie
     class PaymentStateUpdater

      attr_reader :payment
      attr_reader :mollie_order

       def initialize(mollie_order, payment)
         @mollie_order = mollie_order
         @payment = payment
       end
 
       def call
         case mollie_order.status

         when 'created'
            transition_to_created!
         when 'expired'
            transition_to_failed!
         when 'authorized'
            transition_to_pending!
         when 'paid', 'completed'
            transition_to_complete!
         when 'canceled'
            transition_to_void!
         when 'shipping'
            transition_to_shipping!
         else
           MollieLogger.debug("Unhandled Mollie payment state received: #{mollie_order.status}. Therefore we did not update the payment state.")
         end

       end
 
       private

       def transition_to_created!
         true
       end

       def transition_to_failed!
         payment.failure! unless @spree_payment.failed?
       end

       def transition_to_pending!
         payment.pend! unless @spree_payment.pending?
       end

       def transition_to_complete!
         payment.complete! unless @payment.completed?
       end

       def transition_to_void!
         payment.void! unless @payment.void?
       end
 
       def transition_to_shipping!
         true
       end

     end
   end
 end