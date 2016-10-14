class OrderPick < ActiveRecord::Base

  belongs_to :order_detail
  belongs_to :order
  belongs_to :order_shipment
  belongs_to :item
  belongs_to :stock_location, :foreign_key => :location_id
  belongs_to :user

  def self.update_quantities(order_picks, user_id, location_id, order_id)
    order_complete = true
    pick_data = []
    message = ''
    success = true
    order = nil

    if order_picks.present?
      OrderPick.transaction do
        begin

          order = Order.find(order_id)

          order_picks.each do |order_pick|
            picked_qty = order_pick[1]['qty'].to_i rescue 0
            if picked_qty > 0

              od = OrderDetail.find(order_pick[1]['order_detail_id'])

              if picked_qty > od.remaining_qty
                pick_data = []
                raise 'Picked quantity greater than the remaining balance, unable to process.'
              end

              op = OrderPick.new
              op.order_detail_id = od.id
              op.location_id = location_id
              op.item_id = od.item_id
              op.user_id = user_id
              op.order_id = order.id
              op.quantity_picked = picked_qty
              op.item.harmonization_code = order_pick[1]['harmonization_code'] if order_pick[1]['harmonization_code'].present?
              op.item.item_weight = order_pick[1]['item_weight'] if order_pick[1]['item_weight'].present?
              op.item.country_code = order_pick[1]['country_code'] if order_pick[1]['country_code'].present?
              op.item.save


              if op.order_detail.remaining_qty != picked_qty
                order_complete = false
              end
              op.save

              iv = ItemInventory.where(:stock_location_id => op.location_id).where(:item_id => op.item_id).first
              if iv.present? and op.quantity_picked.present? and op.quantity_picked > 0
                iv.current_stock = iv.current_stock - op.quantity_picked
                iv.save
              end

              pick_data << op
            else
              od = OrderDetail.find(order_pick[0])
              if od.remaining_qty > 0
                order_complete = false
              end
            end
          end

          if order.present? and pick_data.length > 0
            ExportPicks.export_pick(pick_data, order) if SystemSetting.check_setting('export_orders', true, order.company_id)
            order.status = Order::STATUS_PICKED
            unless order_complete

              order.clone_for_balance

            end
            order.save
          end
        rescue => exc
          pick_data = []
          message = "An error occurred while processing the pick. #{exc.to_s}"
          success = false
          raise ActiveRecord::Rollback
        end
      end
    end

    {:success => success, :message => message}
  end

end
