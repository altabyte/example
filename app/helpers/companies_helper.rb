module CompaniesHelper

  def company_shipping_services (company_id)
    ShippingService.where("company_id IS NULL or company_id = #{company_id}")
  end

end
