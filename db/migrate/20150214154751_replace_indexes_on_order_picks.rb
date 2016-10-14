class ReplaceIndexesOnOrderPicks < ActiveRecord::Migration
  def change
    remove_index :order_picks, :name => 'order_picks_UK1'
    add_index :order_picks, :order_header_id, :name => 'order_picks_IND1'
    add_index :order_picks, [:order_header_id, :order_detail_id], :name => 'order_picks_IND2'
  end
end
