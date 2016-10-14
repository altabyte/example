class ChannelShippingService < ActiveRecord::Base
  belongs_to :channel
  belongs_to :shipping_service
  has_many :orders

  def self.check_shipping_method(shipping_text, order_value, items, channel_id)

    #TODO needs elaborating over

    shipping_service = ChannelShippingService.find_or_create_by_shipping_text_and_channel_id(shipping_text, channel_id)
    shipping_service
  end
end
