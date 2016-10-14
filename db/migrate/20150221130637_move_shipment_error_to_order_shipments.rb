class MoveShipmentErrorToOrderShipments < ActiveRecord::Migration
  def change
    # remove_column :order_headers, :shipment_error, :shipment_index, :channel_shipping_id,
    #               :delivered_date, :aftership_token,:shipment_check_failed, :aftership_signed_by, :aftership_status
    #
    # add_column :order_shipments, :shipment_error, :string
    # add_column :order_shipments, :channel_shipping_id, :string
    # add_column :order_shipments, :delivered_date, :datetime
    # add_column :order_shipments, :aftership_token, :string
    # add_column :order_shipments, :shipment_check_failed, :string
    # add_column :order_shipments, :aftership_signed_by, :string
    # add_column :order_shipments, :aftership_status, :string
  end
end
