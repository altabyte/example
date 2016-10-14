class ChangeOrderHeaderIdFields < ActiveRecord::Migration
  def change
    rename_column :fedex_shipments, :order_header_id, :order_id
    rename_column :order_errors, :order_header_id, :order_id
    rename_column :order_fraud_scores, :order_header_id, :order_id
    rename_column :order_picks, :order_header_id, :order_id
    remove_index :order_shipments, :name => 'order_shipments_UK1'
    remove_column :order_shipments, :order_id
    rename_column :order_shipments, :order_header_id, :order_id
    rename_column :order_status_histories, :order_header_id, :order_id
    add_index :order_shipments, :order_id, :name => 'order_shipments_IND1'

  end
end
