class OrderDetail < ActiveRecord::Base

  belongs_to :order, :foreign_key => 'order_id'
  belongs_to :item
  belongs_to :order_shipment
  has_many :item_inventories, :through => :item
  has_many :order_picks

  validates_uniqueness_of :channel_order_detail_id, :scope => :order_id

  def country_string
    Country.find_country_by_alpha2(self.order.shipping_address.country).name rescue 'UNKNOWN'
  end

  def quantity_picked
    self.order_picks.sum(:quantity_picked)
  end

  def picking_information
    if order_picks.present?
      pick = order_picks.first
      "#{pick.user.name rescue 'Unknown'} @ #{pick.stock_location.name rescue 'Unknown'}: #{pick.quantity_picked}"
    end
  end

  def show_stock
    show = true
    if order_picks.present?
      if order_picks.first.quantity_picked == self.quantity_ordered
        show = false
      end
    end
    show
  end

  def remaining_qty
    quantity_ordered - order_picks.sum(:quantity_picked)
  end


end
