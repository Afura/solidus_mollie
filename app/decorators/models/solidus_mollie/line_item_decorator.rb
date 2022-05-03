module SolidusMollie
   module LineItemDecorator
   
      def tax_rate
         if adjustments.tax.any?
           # Solidus allows line items to have multiple TaxRate adjustments.
           # Mollie does not support this. Raise an error if there > 1 TaxRate adjustment.

           if adjustments.tax.count > 1
             raise 'Mollie does not support multiple TaxRate adjustments per line item'
           end
           
           adjustments.tax.first.source.amount
         else
           0.00
         end
       end
 
     ::Spree::LineItem.prepend self
   end
  end