class AddOriginalOrderIdToOrder < ActiveRecord::Migration
  def change
    add_column :orders, :original_order_id, :integer
    add_column :orders, :part_order_sequence, :integer, :default => 0
  end
end
