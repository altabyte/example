class ChangeOrderShipments < ActiveRecord::Migration
  def change

    # ActiveRecord::Base.connection.execute("CREATE TABLE order_shipments_old AS SELECT * FROM order_shipments;")
    # OrderShipment.delete_all
    #
    # remove_index :order_shipments, :name => 'order_shipments_UK1'
    # add_column :order_shipments, :shipped, :boolean
    # remove_column :order_shipments, :order_id, :item_id, :quantity_shipped, :order_detail_id
    # rename_column :order_shipments, :stock_location_id, :location_id
    # add_index :order_shipments, :order_header_id, :name => 'order_shipments_IND1'
  end
end
