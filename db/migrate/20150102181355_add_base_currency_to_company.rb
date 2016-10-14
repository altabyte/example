class AddBaseCurrencyToCompany < ActiveRecord::Migration
  def change
    add_column :companies, :base_currency, :string
  end
end
