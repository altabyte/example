class CreateShippingServiceAccountDetails < ActiveRecord::Migration
  def change
    create_table :shipping_service_account_details do |t|
      t.integer :shipping_service_id
      t.integer :stock_location_id
      t.string :account_number

      t.timestamps
    end
  end
end
