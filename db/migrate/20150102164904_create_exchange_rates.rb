class CreateExchangeRates < ActiveRecord::Migration
  def change
    create_table :exchange_rates do |t|
      t.string :from_currency
      t.string :to_currency
      t.integer :company_id
      t.decimal :exchange_rate, :precision => 20, :scale => 10

      t.timestamps
    end
  end
end
