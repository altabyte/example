class ShippingOverride < ActiveRecord::Base
  belongs_to :channel
  belongs_to :shipping_service
end
