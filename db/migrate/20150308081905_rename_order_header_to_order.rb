class RenameOrderHeaderToOrder < ActiveRecord::Migration
  def change
    rename_table :order_headers, :orders
  end

end
