# Should autoload...
require 'mollie-api-ruby'

# Credit

# 1. Webhook Callbacks
# 2. Payment Methods through API
# 3. Create Mollie User
# 4. Mollie shipoments

# X. Client wrapper like PayPal
# X. Ugly functions in serializer
# x. Nice helper for Payment ID
# X. Check if we pass only variables needed

module Spree 
   class Gateway::MollieGateway 

      def initialize(options)
         ::Mollie::Client.configure do |config|
            config.api_key  = options[:api_key]
         end
      end

      def format_money(money)
         Spree::Money.new(money, { symbol: nil, thousands_separator: nil, decimal_mark: '.' }).format
       end

      def auto_capture?
         false # Mollie always auto captures payments, should not be allowed to set as false with preferences
      end

      def authorize(_money, _source, gateway_options = {})
         begin
            payment = gateway_options[:originator]
            invalidate_previous_orders(payment.order_id)

            # Create a new Mollie order and update the payment source
            mollie_order = create_mollie_order(gateway_options)
            payment.source.update(status: mollie_order.status, payment_id: mollie_order.id, payment_url: mollie_order.checkout_url)

            ActiveMerchant::Billing::Response.new(true, 'Order created')
         rescue ::Mollie::Exception => e
            ActiveMerchant::Billing::Response.new(false, "Order could not be created: #{e.message}")
         end
      end

      def capture(_money, _response_code, gateway_options = {})
         authorize(_money, nil, gateway_options)
         # ActiveMerchant::Billing::Response.new(true, 'Mollie will automatically capture the amount.')
      end

      def purchase(money, source, gateway_options = {})
         authorize(money, source, gateway_options = {})
      end

      def void(_respoonse_code, gateway_options = {})
         begin
            payment_id = gateway_options[:originator].source.payment_id

            if cancel_mollie_order!(payment_id)
              ActiveMerchant::Billing::Response.new(true, 'Mollie order has been cancelled.')
            else
              MollieLogger.debug("Spree order #{payment_id} has been canceled, could not cancel Mollie order.")
              ActiveMerchant::Billing::Response.new(true, 'Spree order has been canceled, could not cancel Mollie order.')
            end
          rescue ::Mollie::Exception => e
            MollieLogger.debug("Order #{payment_id} could not be canceled: #{e.message}")
            ActiveMerchant::Billing::Response.new(false, 'Order cancellation unsuccessful.')
          end
      end

      def credit(_money_cents, _transaction_id, options)

         refund = options[:originator]

         payment = refund.try(:payment)
         order = payment.try(:order)
         reimbursement = refund.try(:reimbursement)

         binding.pry

         begin
            if reimbursement

               mollie_order = ::Mollie::Order.get(payment.source.payment_id)

               mollie_order_refund_lines = reimbursement.return_items.map do |reimbursement|
                  line_item = mollie_order.lines.detect { |line| line_item.sku == reimbursement.inventory_unit.line_item.mollie_identifier }
                  { id: line_item.id, quantity: ri.inventory_unit.line_item.quantity } if line_item
               end.compact

               mollie_order.refund!({lines: mollie_order_refund_lines})
            else
               ::Mollie::Payment::Refund.create(
                  payment_id: payment_id,
                  amount: {
                        value: format_money(refund.amount),
                        currency: refund.currency
                  },
                  description: "Refund Order ID: #{order.number}",

               )
            end
            ActiveMerchant::Billing::Response.new(true, "Successfully refunded #{order.display_total} for order #{order_number}")
         rescue ::Mollie::Exception => e
            ActiveMerchant::Billing::Response.new(false, e.message)
         end
      end

      def available_methods(params = nil)
         method_params = {
            include: 'issuers',
            resource: 'orders'
         }
   
         method_params.merge! params if params.present?
   
         ::Mollie::Method.all(method_params)
      end
   
      def available_methods_for_order(order)
         params = {
            amount: {
               currency: order.currency,
               value: format_money(order.total)
            },
            resource: 'orders',
            billingCountry: order.billing_address.country.try(:iso)
         }
         available_methods(params)
      end

      def update_payment_status(payment)
         mollie_order = ::Mollie::Order.get(payment.source.payment_id, embed: 'payments')
   
         Spree::Mollie::PaymentStateUpdater.new(mollie_order, payment).call
       end

      private
      
      def create_mollie_order(gateway_options)
         order_params = Spree::Mollie::OrderSerializer.serialize(gateway_options)

         ::Mollie::Order.create(order_params)
      end

      def cancel_mollie_order!(payment_id)
         mollie_order = ::Mollie::Order.get(payment_id)
         mollie_order.cancel if mollie_order.cancelable?
      end
   
      def invalidate_previous_orders(order_id)
         #TODO: Nice scope that checks for Payment Source
         # Spree::Payment.by_mollie_and_order(order_id).each { cancel_mollie_order(paymnet) }

         Spree::Payment.where(order_id: order_id).where("state = ? OR state = ?", 'pending', 'processing').each do |payment|
            if payment.source_type == "Spree::MolliePaymentSource"
               payment.void!
               cancel_mollie_order!(payment.source.payment_id)
            end
         end
      end
      
   end
end