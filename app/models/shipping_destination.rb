class ShippingDestination < ActiveRecord::Base
  attr_accessible :company_id, :country_code, :harmonization_code_required, :item_county_of_origin_required, :item_weight_required
  validates_presence_of :country_code
  validates_uniqueness_of :country_code, :scope => :company_id
end
