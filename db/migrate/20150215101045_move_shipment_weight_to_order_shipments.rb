class MoveShipmentWeightToOrderShipments < ActiveRecord::Migration
  def change
    # remove_column :order_headers, :shipping_weight, :company_packaging_type_id, :package_height,:package_width, :package_length, :override_shipping_service_id
    # add_column :order_shipments, :shipping_weight, :decimal, :precision => 6, :scale => 2
    # add_column :order_shipments, :package_height, :decimal, :precision => 6, :scale => 2
    # add_column :order_shipments, :package_width, :decimal, :precision => 6, :scale => 2
    # add_column :order_shipments, :package_length, :decimal, :precision => 6, :scale => 2
    # add_column :order_shipments, :company_packaging_type_id, :integer
    # rename_column :order_shipments, :shipping_method_id, :shipping_service_id
  end
end
