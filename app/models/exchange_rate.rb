class ExchangeRate < ActiveRecord::Base
  attr_accessible :exchange_rate, :from_currency, :to_currency, :company_id

  belongs_to :company

  validates_uniqueness_of :to_currency, :scope => :company_id
  validates_presence_of :exchange_rate


  def self.get_latest(company_id)
    ExchangeRate.delete_all(:company_id => company_id)
    company = Company.find(company_id)
    result = true
    if company.present?
      if company.base_currency.present?
        begin
          require 'net/http'
          source = 'http://openexchangerates.org/api/latest.json?app_id=806ed6b893e6418999e0979a7233fb87'
          resp = Net::HTTP.get_response(URI.parse(source))
          data = resp.body
          result = JSON.parse(data, :symbolize_names => true)
          company_base_exchange = result[:rates][company.base_currency.to_sym]
          result[:rates].each do |k, v|
            unless k.to_s == company.base_currency
              if ApplicationController.helpers.currency_collection.find { |h| h[1] == k.to_s }
                to_currency_exch = v / company_base_exchange
                ExchangeRate.create(:from_currency => company.base_currency, :to_currency => k, :exchange_rate => to_currency_exch, :company_id => company_id)
              end
            end
          end
          return {:result => true, :message => ''}
        rescue => exc
          return {:result => false, :message => exc.to_s}
        end
      else
        return {:result => false, :message => 'Company base rate not set.  Please set on Basic Details tab.'}
      end
    end
  end

  def self.convert(currency, value, company)
    base_currency = company.base_currency
    return value if base_currency.blank? or base_currency == currency
    rate = ExchangeRate.where(:company_id => company.id).where(:from_currency => base_currency).where(:to_currency => currency).first

    if rate.present?
      return (sprintf "%.2f", (value.to_d / rate.exchange_rate).to_d rescue value)
    else
      return value
    end
  end
end

