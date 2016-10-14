class OrderError < ActiveRecord::Base
  attr_accessible :error, :order_id, :process
  belongs_to :order
end
