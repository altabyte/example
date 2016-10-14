class ItemInventory < ActiveRecord::Base
  attr_accessible :current_stock, :item_id, :stock_location_id
  belongs_to :item
  belongs_to :stock_location
end
