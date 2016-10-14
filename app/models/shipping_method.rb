class ShippingMethod < ActiveRecord::Base

  has_many :shipping_services, :dependent => :destroy
  accepts_nested_attributes_for :shipping_services, :allow_destroy => true
  validates_uniqueness_of :name
  validates_presence_of :name

  def self.reset_aftership_codes
    ShippingMethod.update_all('aftership_code = "royal-mail"', 'code = "RM"')
    ShippingMethod.update_all('aftership_code = "royal-mail"', 'code = "RMPO"')
    ShippingMethod.update_all('aftership_code = "fedex"', 'code = "FDX"')
    ShippingMethod.update_all('aftership_code = "dpd"', 'code = "DPD"')
    ShippingMethod.update_all('aftership_code = "dpd-ireland"', 'code = "DPD-IE"')
  end
end
