# frozen_string_literal: true

json.(@payment, *payment_attributes)
json.(@payment.source, :payment_url)
#FIXME: This works, but I think there is a better way than overwriting this template