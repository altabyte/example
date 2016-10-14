class DmoOrderShipmentJob < Struct.new(:orders, :current_location, :company)

  def perform

    begin
      start_time = DateTime.now()
      location = StockLocation.find(current_location)
      require 'fileutils'
      base_dir = Rails.root.join('export', company.client_share, 'order_shipping', 'dmo', location.name)
      import_data_path = "#{base_dir}/import"
      export_data_path = "#{base_dir}/export"

      FileUtils.mkpath(import_data_path)
      FileUtils.mkpath(export_data_path)

      data_file = export_data_path + "/Data.txt"
      lock_file = export_data_path + "/Lock.txt"
      result_file = import_data_path + "/Result.txt"
      #result_file = data_path + "Result.txt"
      text_file = ""

      if File.exist?(data_file)
        File.delete(data_file)
      end

      if File.exist?(lock_file)
        File.delete(lock_file)
      end

      if File.exist?(result_file)
        File.delete(result_file)
      end

      text_file_header = ""
      text_file_header = "ADD ORDER_MANAGER\n"

      orders.each do |order|

        text_file << order.actual_shipping_service.service_reference rescue ""
        text_file << ","
        text_file << order.actual_shipping_service.royal_mail_service
        text_file << ","
        text_file << order.actual_shipping_service.royal_mail_service_enhancement rescue ""
        text_file << ","
        text_file << order.actual_shipping_service.royal_mail_service_class rescue ""
        text_file << ","
        text_file << order.actual_shipping_service.royal_mail_service_format rescue ""
        text_file << ","
        text_file << order.shipping_name
        text_file << ","
        text_file << order.shipping_address.address_1.gsub(/([^\n])\n([^\n])/, '\1 \2').gsub(',', ' ') rescue ""
        text_file << ","
        text_file << order.shipping_address.address_2.gsub(/([^\n])\n([^\n])/, '\1 \2').gsub(',', ' ') rescue ""
        text_file << ","
        text_file << order.shipping_address.county.gsub(',', ' ') rescue ""
        text_file << ","
        text_file << order.shipping_address.town.gsub(',', ' ') rescue ""
        text_file << ","
        text_file << order.shipping_address.post_code.gsub(',', ' ') rescue ""
        text_file << ","
        text_file << order.shipping_address.country.gsub(',', ' ') rescue ""
        text_file << ","
        if order.shipping_address.telephone.present? and order.shipping_address.telephone.start_with?('07')
          telephone = order.shipping_address.telephone.gsub(',', ' ') rescue ""
        else
          telephone = ""
        end
        text_file << telephone
        text_file << ","
        text_file << "#{order.customer.email}" rescue ''
        text_file << ","
        text_file << "#{order.channel_order_id.to_s}"
        text_file << ","
        text_file << "1"
        text_file << ","

        if order.shipping_weight.present?
          weight = order.shipping_weight.to_s
        else
          weight = order.actual_shipping_service.weight.to_s
        end
        text_file << sprintf("%.2f", weight)

        text_file << "\n"
      end

      if text_file.present?
        my_file = File.new(lock_file, "w")
        my_file.write text_file_header
        my_file.write text_file
        my_file.close
      end

      if text_file.present?
        my_file = File.new(data_file, "w")
        my_file.write text_file_header
        my_file.write text_file
        my_file.close
      end


      10.times do
        Rails.logger.info("check for file")
        if File.exist?(result_file)
          break
        end
        sleep(30)
      end


      if File.exist?(result_file)
        result_array = IO.readlines(result_file)
        orders.each_with_index do |order, index|
          Rails.logger.info("check for file #{result_array.in_groups_of(3)[index]}")
          line_1 = result_array.in_groups_of(3)[index][0].strip rescue nil
          line_2 = result_array.in_groups_of(3)[index][1].strip rescue nil
          line_3 = result_array.in_groups_of(3)[index][2].strip rescue nil
          if line_1.to_s.include?("0")
            Rails.logger.info("line2=#{result_array.in_groups_of(3)[index][1]} :: #{line_2}")
            order.tracking_details = line_2.squish.to_s rescue nil
            order.ship_order
            order.save!
          else
            if line_3.present?
              order.shipment_error = line_3.squish.to_s
            elsif line_2.present?
              order.shipment_error = line_2.squish.to_s
            end

            order.update_status(Order::STATUS_WEIGHED)

            CompanyLog.create(
                :company_id => company.id,
                :log_level => 'ERROR',
                :date_timestamp => DateTime.now(),
                :message => ("Royal Mail DMO Failed @ #{location.name}: Error returned from DMO #{order.shipment_error} Shipment ID:#{order.id}")
            )

          end
        end
        File.delete(result_file)
      else
        orders.each do |order|
          order.update_status(Order::STATUS_WEIGHED)
          order.shipment_error = 'No Response'
          order.save
        end
        message = ""
        if File.exist?(data_file)
          message += " Data.txt still exists."
        end

        if File.exist?(lock_file)
          message += " Lock.txt still exists."
        end


        CompanyLog.create(
            :company_id => company.id,
            :log_level => 'ERROR',
            :date_timestamp => DateTime.now(),
            :message => ("Royal Mail DMO Failed @ #{location.name}: FTP Problem? Result.txt not received within timescale" + message + ". Process Start Time #{I18n.l(start_time)}")
        )

      end


    rescue => ex
      orders.each do |order|
        if order.tracking_details.blank?
          order.update_status(Order::STATUS_WEIGHED)
          order.shipment_error = ex.to_s
          order.save!
        end
      end
      Rollbar.error(ex)
      Rails.logger.error(ex)

    ensure
      if File.exist?(data_file)
        File.delete(data_file)
      end

      if File.exist?(lock_file)
        File.delete(lock_file)
      end

      if File.exist?(result_file)
        File.delete(result_file)
      end

    end


  end

  def max_attempts
    return 1
  end

  def error(job, exception)

  end

end