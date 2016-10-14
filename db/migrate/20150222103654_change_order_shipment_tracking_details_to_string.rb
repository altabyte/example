class ChangeOrderShipmentTrackingDetailsToString < ActiveRecord::Migration
  def change
    change_column :order_shipments, :tracking_details, :string
  end
end
