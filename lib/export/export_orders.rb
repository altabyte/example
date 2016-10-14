require 'rexml/document'

module ExportOrders
  def self.get_export_order_list(params, company_id)
    begin
      last_updated_at = DateTime.strptime(params[:last_updated_at], "%d/%m/%Y %H:%M") if params[:last_updated_at]

      orders = Order.where(:company_id => company_id).where("updated_at >=? ", last_updated_at)
      if orders.present?
        builder = Nokogiri::XML::Builder.new do |xml|
          xml.OrderList {
            orders.each do |order|
              xml.Order order.id
            end
          }
        end
        return {:status => :success, :data => builder.to_xml}
      else
        return {:status => :no_data}
      end
    rescue => exc
      return {:status => :failure, :message => exc}
    end
  end

  def self.get_export_file(params, company_id)
    begin
      order = Order.find_by_id_and_company_id(params[:order_id], company_id)
      if order.present? and order.order_xml.present?
        builder = Nokogiri.parse(order.order_xml)
        return {:status => :success, :data => builder.to_xml}
      else
        return {:status => :no_data}
      end
    rescue => exc
      return {:status => :failure, :message => exc}
    end
  end

end