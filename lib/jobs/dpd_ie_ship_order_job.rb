class DpdIeShipOrderJob < Struct.new(:orders, :current_location, :company)

  def perform

    location = StockLocation.find(current_location)
    require 'fileutils'
    data_path = Rails.root.join('export', company.client_share, 'order_shipping', 'dpd', location.name, 'import')
    FileUtils.mkpath(data_path)

    data_file = data_path + "dpd_import_#{Time.now.strftime("%Y-%m-%d-%H%M%S")}.csv"
    text_file = ""
    orders.each do |order|
      if order.shipping_address.company.present?
        customer_name = order.shipping_address.company.gsub(',', ' ')
      else
        customer_name = order.shipping_name
      end

      text_file << "#{order.channel_order_id}" + ",,"
      text_file << customer_name + ","
      text_file << order.shipping_address.address_1.gsub(/([^\n])\n([^\n])/, '\1 \2').gsub(',', ' ') rescue ""
      text_file << ","
      text_file << order.shipping_address.address_2.gsub(/([^\n])\n([^\n])/, '\1 \2').gsub(',', ' ') rescue ""
      text_file << ","
      text_file << order.shipping_address.town.gsub(',', ' ') rescue ""
      text_file << ","
      text_file << order.shipping_address.county.gsub(',', ' ') rescue ""
      text_file << ","

      country_code = Country.find_country_by_alpha2(order.shipping_address.country)
      if country_code.present?
        delivery_country = country_code.number
      else
        delivery_country = nil
      end
      delivery_service = order.actual_shipping_service.dpd_service.present? ? order.actual_shipping_service.dpd_service : '2'
      if delivery_country == "372"
        text_file << ","
      else
        text_file << order.shipping_address.post_code.gsub(',', ' ') rescue ""
        text_file << ","
      end

      if order.shipping_address.post_code.to_s.starts_with?('BT') or order.shipping_address.post_code.to_s.starts_with?('bt') or delivery_country == "372"
        delivery_service = "O"
      end

      if order.shipping_address.post_code.to_s.starts_with?('BT') or order.shipping_address.post_code.to_s.starts_with?('bt')
        delivery_country = "372"
      end

      text_file << delivery_country.gsub(',', ' ') rescue ""
      text_file << ","
      text_file << "1,"
      text_file << "0,"
      text_file << "N,"
      text_file << delivery_service.gsub(',', ' ') + ","
      text_file << ","
      text_file << ",,,,,,,,,"
      text_file << order.shipping_name + ","
      text_file << (order.shipping_address.telephone.gsub(',', ' ') rescue '') + ","
      text_file << ",,,"

      account_number = ShippingServiceAccountDetail.where(:stock_location_id => location.id).where(:shipping_service_id => order.actual_shipping_service.id).first.account_number rescue nil
      account_number =order.actual_shipping_service.account_number if account_number.blank?

      text_file << "#{account_number},"
      text_file << "#{order.customer.email},Y," rescue ''

      if order.shipping_address.telephone.blank? or !order.shipping_address.telephone.to_s.starts_with?('07')
        text_file << "N"
      else
        text_file << "Y,#{order.shipping_address.telephone.gsub(',', ' ')}"
      end

      text_file << "\n"
    end

    if text_file.present?
      my_file = File.new(data_file, "w")
      my_file.write text_file
      my_file.close
    end
  end

end