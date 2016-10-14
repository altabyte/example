class ShippingService < ActiveRecord::Base
  include ActionView::Helpers::NumberHelper
  belongs_to :shipping_method
  has_many :channel_shipping_services
  validates_presence_of :name
  validates_presence_of :shipping_method_id
  validates_uniqueness_of :name, :scope => :location_id
  validates :default_weight, :numericality => {:greater_than_or_equal_to => 0, :less_than_or_equal_to => 15}, :unless => 'default_weight.blank?'
  validates_numericality_of :fedex_package_height, :if => "fedex_package_type=='YOUR_PACKAGING'"
  validates_numericality_of :fedex_package_width, :if => "fedex_package_type=='YOUR_PACKAGING'"
  validates_numericality_of :fedex_package_length, :if => "fedex_package_type=='YOUR_PACKAGING'"
  belongs_to :location, :class_name => "StockLocation", :foreign_key => "location_id"
  belongs_to :company

  has_many :shipping_service_account_details, :dependent => :destroy
  accepts_nested_attributes_for :shipping_service_account_details, :allow_destroy => true

  after_save :delete_unused_account_details

  def delete_unused_account_details
    ShippingServiceAccountDetail.delete_all("shipping_service_id = #{self.id} and (account_number IS NULL or account_number = '')")
  end


  def has_channel_shipping_services?
    collection = self.channel_shipping_services
    collection.count > 0
  end

  def weight
    weight = '1.0'
    if self.default_weight.present?
      weight = self.default_weight
    elsif self.shipping_method.default_weight.present?
      weight = self.shipping_method.default_weight
    end
    number_with_precision(weight, :precision => 1)
  end

  def self.get_available_rate(order_id, weight, company_packing_type_id, dimensions, current_location_id)

    weight = weight.to_d

    order = Order.find(order_id)
    company_id = order.channel.company_id
    rates = []
    pkg_type = CompanyPackagingType.find(company_packing_type_id)

    available_rates = ShippingMatrix.
        where(:company_id => company_id).
        where(:country => order.shipping_address.country).
        where("#{order.subtotal} between order_subtotal_from and order_subtotal_to").
        where("#{weight} between weight_from and weight_to").
        joins('left outer join shipping_services on shipping_services.id = shipping_matrices.shipping_service_id').
        where("shipping_services.location_id = #{current_location_id} or shipping_services.location_id is null")

    if order.channel_shipping_service.next_day == 'Y'
      available_rates = available_rates.where("next_day = 'Y'")
    end


    available_rates.each do |rate|

      cost = rate.shipping_cost
      rates <<
          {
              :shipping_service_id => rate.shipping_service_id,
              :shipping_cost => cost,
              :name => ("#{rate.shipping_service.shipping_method.name}: #{rate.shipping_service.name}")
          }

    end

    if order.channel.company.fedex_setting.present? and (pkg_type.packaging_type.fedex or pkg_type.packaging_type.ad_hoc or pkg_type.packaging_type.custom)

      begin

        if pkg_type.packaging_type.custom
          fedex_data = {
              :package_type => 'YOUR_PACKAGING',
              :package_height => pkg_type.height,
              :package_width => pkg_type.width,
              :package_length => pkg_type.length

          }
        elsif pkg_type.packaging_type.ad_hoc
          fedex_data = {
              :package_type => 'YOUR_PACKAGING',
              :package_height => dimensions['package_height'],
              :package_width => dimensions['package_width'],
              :package_length => dimensions['package_length']

          }
        else
          fedex_data = {
              :package_type => pkg_type.packaging_type.name

          }
        end

        fdx_rate = []
        begin
          fdx_rate = FedexSetting.get_rates(order, weight, fedex_data)
        rescue
          puts $!.inspect.to_s
        end

        if fdx_rate.present?
          fdx_shipping_method = ShippingMethod.find_by_code('FDX')


          fdx_rate.each do |rate|
            rate_service = ShippingService.find_by_name_and_shipping_method_id(rate.service_type, fdx_shipping_method.id)
            rates <<
                {
                    :shipping_service_id => rate_service.id,
                    :shipping_cost => rate.total_net_charge.to_d,
                    :name => ("FEDEX: #{rate.service_type.to_s.titleize}")
                }
          end
        end


      end
    else


    end
    rates.sort_by { |hsh| hsh[:shipping_cost] }
  end

  def build_account_details
    stock_locations = self.company.stock_locations.where('stock_only = 0 or stock_only IS NULL')
    stock_locations.each do |loc|
      ShippingServiceAccountDetail.find_or_create_by_shipping_service_id_and_stock_location_id(self.id, loc.id)
    end
  end
end
