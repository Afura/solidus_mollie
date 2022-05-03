module SolidusMollie
    class OrderSerializer
    #  include ::Spree::Mollie::MoneyFormatter

      def self.serialize(gateway_options)
        new(gateway_options).serialize
      end

      def initialize(gateway_options)
        @gateway_options = gateway_options
        @source = @gateway_options[:originator].source
        @order = Spree::Order.find(@gateway_options[:originator].order_id)
      end

      def serialize
        spree_routes = ::Spree::Core::Engine.routes.url_helpers
        payment_identifier = @gateway_options[:order_id]

        order_params = {
          amount: price(@order.total),
          metadata: {
            order_number: @order.number,
            payment_identifier: payment_identifier
          },
          orderNumber: payment_identifier,
          redirectUrl: spree_routes.mollie_validate_payment_mollie_url(
            order_number: payment_identifier,
            host: Spree::Store.default.url
          ),
          webhookUrl: spree_routes.mollie_update_payment_status_mollie_url(
            payment_identifier: payment_identifier,
            host: Spree::Store.default.url
          ),
          locale: 'en_US',
        }

        if @gateway_options[:billing_address].present?
          order_params.merge! ({
            billingAddress: serialize_address(@gateway_options[:billing_address])
          })
        end

        if @gateway_options[:shipping_address].present?
          order_params.merge! ({
            shippingAddress: serialize_address(@gateway_options[:shipping_address])
          })
        end

        order_params.merge! ({
          lines: prepare_line_items
        })

        # User has already selected a payment method
        if @source.try(:payment_method_name).present?
          order_params.merge! ({
            method: @source.payment_method_name
          })
        end

        # User has selected an issuer (available for iDEAL payments)
        if @source.try(:issuer).present?
          order_params.merge! ({
            payment: {
              issuer: @source.issuer
            }
          })
        end

        order_params
      end

      private

      def prepare_line_items
        order_lines = []
        @order.line_items.each do |line|
          order_lines << serialize_line_item(line)
        end

        order_lines << serialize_discounts if @order.adjustments.any?

        order_lines << serialize_shipping_costs

        # if @order.shipping_discount.positive?
        #   order_lines << serialize_shipping_discounts
        # end

        order_lines
      end

      def serialize_address(address)
        {
          streetAndNumber: [address[:address1], address[:address2]].join(" "),
          city: address[:city],
          postalCode: address[:zip],
          country: address[:country],
          region: address[:state],
          givenName: address[:name],
          familyName: address[:name],
          email: @order.email
        }
      end

      def serialize_shipping_costs
        {
          type: 'shipping_fee',
          name: 'Shipping',
          quantity: 1, # Considering shipment as one line item per order and not per item or package
          unitPrice: price(@order.shipments.map(&:cost).inject(0, &:+).to_f + @order.shipments.map(&:adjustment_total).inject(0, &:+).to_f),
          totalAmount: price(@order.shipments.map(&:cost).inject(0, &:+).to_f + @order.shipments.map(&:adjustment_total).inject(0, &:+).to_f),
          vatAmount: price(format_money(@order.shipments.map(&:included_tax_total).inject(0, &:+).to_f)), #TODO: Extract to its own method
          vatRate: @order.shipments.first.tax_category.tax_rates.first.amount.to_f * 100 #TODO: Mollie allows only one tax rate, extract to method
        }
      end

      def serialize_discounts
        binding.pry #TODO: Not implemented
        {
          type: 'discount',
          name: 'Order discount',
          quantity: 1,
          unitPrice: price(@order.display_order_adjustment_total),
          totalAmount: price(@order.display_order_adjustment_total),
          vatAmount: price(0),
          vatRate: '0'
        }
      end

      def serialize_shipping_discounts
        binding.pry #TODO: Not implemented
        {
          type: 'discount',
          name: 'Shipping discount', 
          quantity: 1,
          unitPrice: price(@order.display_shipping_discount),
          totalAmount: price(@order.display_shipping_discount),
          vatAmount: price(0),
          vatRate: '0'
        }
      end

      def serialize_line_item(line_item)
        {
          type: 'physical',
          name: line_item.name,
          quantity: line_item.quantity,
          unitPrice: price(line_item.price),
          discountAmount: price(line_item.promo_total),
          totalAmount: price(line_item.total),
          vatAmount: price(line_item.included_tax_total),
          vatRate: line_item.tax_rate.to_f * 100, # TODO: Might need to verify this rates just one tax_rate
          sku: line_item.sku
        }
      end

      def price(amount)
        {
          value: format_money(amount),
          currency: @order.currency
        }
      end

      def format_money(money)
        Spree::Money.new(money, { symbol: nil, thousands_separator: nil, decimal_mark: '.' }).format
      end
    end
 end