class StockLocationUser < ActiveRecord::Base

  belongs_to :stock_location
  belongs_to :user

  validates_uniqueness_of :user_id, :scope => :stock_location_id
end
