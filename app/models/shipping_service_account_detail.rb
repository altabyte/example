class ShippingServiceAccountDetail < ActiveRecord::Base
  attr_accessible :account_number, :shipping_service_id, :stock_location_id
  belongs_to :stock_location
  belongs_to :shipping_service
end
