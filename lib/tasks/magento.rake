require "net/http"
require "uri"


namespace :magento do


  desc "Get Product Information"
  task :get_product_info => :environment do
    missing_product_info = Item.where('colour IS NULL or `size` IS NULL or name is null')
    system_channel = SystemChannel.find_by_name("MAGENTO")
    master_channel = Channel.find_by_system_channel_id_and_product_master(system_channel.id, 'Y')
    if master_channel.present? and missing_product_info.present?
      missing_product_info.each do |missing_info|
        begin
          Rails.logger.info("Connecting to Magento to get product information for #{missing_info.sku}")
          http = Net::HTTP.new(master_channel.connection_1, 80)
          response = http.request(Net::HTTP::Get.new("/scripts/flat_item_data.php?sku=#{missing_info.sku}"))
          doc = REXML::Document.new(response.body.to_s.force_encoding("UTF-8"))
          doc.elements.each('items/item') do |update_item|
            missing_info.name = update_item.elements['name'].text if update_item.elements['name'].present?
            missing_info.colour = update_item.elements['color_value'].text if update_item.elements['color_value'].present?
            missing_info.size = update_item.elements['size_value'].text if update_item.elements['size_value'].present?
            missing_info.item_weight = update_item.elements['item_weight'].text if update_item.elements['item_weight'].present?
            missing_info.country_code = update_item.elements['country_code'].text if update_item.elements['country_code'].present?
            missing_info.harmonization_code = update_item.elements['harmon_code'].text if update_item.elements['harmon_code'].present?
            missing_info.save!
          end
        rescue => exc
          Rails.logger.info("Error getting product form master channel:  #{exc.to_s}")
        end
      end
    end
  end

  desc 'update_channel'
  task :update_chanel => :environment do
    orders_to_update = Order.find_all_by_status(Order::STATUS_DISPATCHED)

    orders_to_update.each do |order|

      if order.channel.system_channel.name == "MAGENTO" and order.channel_shipping_id.blank?
        Magento::Base.connection = Magento::Connection.new({
                                                               :username => order.channel.connection_2,
                                                               :api_key => Channel.decrypt(:password_1, order.channel.password_1_encrypted),
                                                               :host => order.channel.connection_1,
                                                               :path => '/api/xmlrpc',
                                                               :port => '80'
                                                           })

        shipment_id = Magento::Shipment.create(order.channel_order_id, nil, nil, true, false, order.actual_shipping_service.shipping_method.tracking_information, order.actual_shipping_service.shipping_method.name, order.tracking_details)
        order.channel_shipping_id = shipment_id.increment_id
        order.save
        if shipment_id.present?
          order.update_status(Order::STATUS_COMPLETE)
        end
      end

      #amazon
    end
  end

  desc "Download Orders"
  task :download_orders => :environment do

    process_start = DateTime.now()

    system_channel = SystemChannel.find_by_name("MAGENTO")
    update_channel=false
    Channel.find_all_by_system_channel_id(system_channel.id).each do |magento_channel|
      orders_to_process = []
      magento_channel.custom_logging("#{CustomLogger::DOWNLOADING_ORDERS} #{magento_channel.name}")

      Magento::Base.connection = Magento::Connection.
          new({
                  :username => magento_channel.connection_2,
                  :api_key => Channel.decrypt(:password_1, magento_channel.password_1_encrypted),
                  :host => magento_channel.connection_1,
                  :path => '/api/xmlrpc',
                  :port => '80'
              })

      filters = {}

      store_view = Magento::Store.find_by_view_code((magento_channel.connection_3.present? ? magento_channel.connection_3 : 'default'))

      if store_view

        filters["store_id"] = {:eq => store_view.id}

        if magento_channel.channel_updated_at("ORDER").present?
          puts "Channel last updated at: #{magento_channel.channel_updated_at("ORDER")}"
          if magento_channel.download_overlap.present? and magento_channel.download_overlap.to_i > 0
            orderlap_mins = magento_channel.download_overlap.to_i
            puts "Configured Overlap Time: #{orderlap_mins}"
            updated_at = magento_channel.channel_updated_at("ORDER") - orderlap_mins.minutes
          else
            updated_at = magento_channel.channel_updated_at("ORDER")
          end
          updated_at = updated_at.strftime("%Y-%m-%d %H:%M:%S")

          filters["updated_at"] = {:gt => updated_at}
        else
          filters["updated_at"] = {:gt => 1.week.ago.strftime("%Y-%m-%d %H:%M:%S")}
        end

        puts "Channel Filters: #{filters["updated_at"]}"

        magento_channel.custom_logging("Getting orders greater than: #{filters["updated_at"][:gt]}")

        updated_orders = Magento::Order.list(filters)

        updated_orders.each do |channel_orders|
          channel_order = Magento::Order.find_by_increment_id(channel_orders.increment_id)
          magento_channel.custom_logging("#{CustomLogger::PROCESSING_ORDER} #{magento_channel.name}::#{channel_order.increment_id}")

          currency = channel_order.order_currency_code

          if channel_order.customer_firstname.blank? and channel_order.customer_lastname.blank?
            customer_full_name = channel_order.billing_address.firstname.to_s.titleize + " " + channel_order.billing_address.lastname.to_s.titleize
          else
            customer_full_name = channel_order.customer_firstname.to_s.titleize + " " + channel_order.customer_lastname.to_s.titleize
          end

          customer = {
              :full_name => customer_full_name.to_s.squish,
              :email => channel_order.customer_email.to_s.downcase
          }

          add_line_1 = ''
          add_line_2 = ''

          lines = channel_order.billing_address.street.split(/\n/)
          lines.each_with_index do |line, index|
            if index == 0
              add_line_1 = line.to_s.titleize
            else
              add_line_2 = line.to_s.titleize
            end
          end

          if add_line_1.blank?
            add_line_1 = lines
            add_line_2 = ''
          end

          if channel_order.billing_address.present?
            customer_billing_address = {
                :address_id => channel_order.billing_address.address_id,
                :address_line_1 => add_line_1,
                :address_line_2 => add_line_2,
                :town => (channel_order.billing_address.city.to_s.upcase rescue ''),
                :company => (channel_order.billing_address.company.to_s.upcase rescue ''),
                :county => (channel_order.billing_address.region.to_s.titleize rescue ''),
                :country => (Country.new(channel_order.billing_address.country.iso2_code).alpha2 rescue 'GB'),
                :post_code => (channel_order.billing_address.postcode.to_s.upcase),
                :telephone => (channel_order.billing_address.telephone rescue '')
            }
          end

          add_line_1 = ''
          add_line_2 = ''

          lines = channel_order.shipping_address.street.split(/\n/)
          lines.each_with_index do |line, index|
            if index == 0
              add_line_1 = line.to_s.titleize
            else
              add_line_2 = line.to_s.titleize
            end
          end

          if add_line_1.blank?
            add_line_1 = lines
            add_line_2 = ''
          end

          shipping_name = channel_order.shipping_address.firstname.to_s.titleize + " " + channel_order.shipping_address.lastname.to_s.titleize
          customer_shipping_address = {
              :address_id => channel_order.shipping_address.address_id,
              :name => shipping_name,
              :address_line_1 => add_line_1,
              :address_line_2 => add_line_2,
              :town => (channel_order.shipping_address.city.to_s.upcase rescue ''),
              :company => (channel_order.shipping_address.company.to_s.upcase rescue ''),
              :county => (channel_order.shipping_address.region.to_s.titleize rescue ''),
              :country => (Country.new(channel_order.shipping_address.country.iso2_code).alpha2 rescue 'GB'),
              :post_code => (channel_order.shipping_address.postcode.to_s.upcase),
              :telephone => (channel_order.shipping_address.telephone rescue '')
          }

          order_items = []

          channel_order.order_items.each do |order_item|
            if order_item.product_type == 'simple'
              product_size = ''
              product_colour = ''
              country_code = ''
              harmonization_code = ''
              item_weight = ''
              http = Net::HTTP.new(magento_channel.connection_1, 80)
              response = http.request(Net::HTTP::Get.new("/scripts/flat_item_data.php?sku=#{order_item.sku}"))
              doc = REXML::Document.new(response.body.to_s.force_encoding("UTF-8"))
              doc.elements.each('items/item') do |update_item|
                product_colour = update_item.elements['color_value'].text if update_item.elements['color_value'].present?
                product_size = update_item.elements['size_value'].text if update_item.elements['size_value'].present?
                country_code = update_item.elements['country_code'].text if update_item.elements['country_code'].present?
                harmonization_code = update_item.elements['harmon_code'].text if update_item.elements['harmon_code'].present?
                item_weight = update_item.elements['item_weight'].text if update_item.elements['item_weight'].present?
              end

              order_items << {
                  :order_detail_id => order_item.item_id,
                  :sku => order_item.sku,
                  :name => order_item.name,
                  :colour => (product_colour["label"] rescue nil),
                  :size => (product_size["label"] rescue nil),
                  :qty_ordered => order_item.qty_ordered.to_i,
                  :unit_price => ExchangeRate.convert(currency, order_item.price, magento_channel.company),
                  :vat_amount => ExchangeRate.convert(currency, order_item.tax_amount, magento_channel.company),
                  :country_of_origin => country_code,
                  :harmonization_code => harmonization_code,
                  :item_weight => item_weight
              }
            end
          end

          http = Net::HTTP.new(magento_channel.connection_1, 80)
          response = http.request(Net::HTTP::Get.new("/scripts/fraud_enq.php?order_id=#{channel_order.increment_id}&format=json"))
          result = JSON.parse(response.body)
          if result.present?
            order_fraud_score = {
                :last_four_digits => result["fraud_score"]["last_four_digits"],
                :avscv2 => result["fraud_score"]["avscv2"],
                :address_result => result["fraud_score"]["address_result"],
                :postcode_result => result["fraud_score"]["postcode_result"],
                :cv2result => result["fraud_score"]["cv2result"],
                :threed_secure_status => result["fraud_score"]["threed_secure_status"],
                :thirdman_action => result["fraud_score"]["thirdman_action"],
                :thirdman_score => result["fraud_score"]["thirdman_score"].to_i
            }
          end

          payment_information=''
          payment_information = channel_order.payment['method'] if channel_order.payment.present? and channel_order.payment['method'].present?

          orders_to_process << {
              :channel_id => magento_channel.id,
              :channel_name => magento_channel.name,
              :order_id => channel_order.increment_id,
              :shipping_service => channel_order.shipping_description,
              :order_date => channel_order.created_at,
              :order_status => channel_order.status,
              :order_total => ExchangeRate.convert(currency, channel_order.grand_total, magento_channel.company),
              :shipping_cost => ExchangeRate.convert(currency, channel_order.shipping_amount, magento_channel.company),
              :vat_amount => ExchangeRate.convert(currency, channel_order.tax_amount, magento_channel.company),
              :sub_total => ExchangeRate.convert(currency, channel_order.subtotal, magento_channel.company),
              :order_items => order_items,
              :customer => customer,
              :billing_address => customer_billing_address,
              :shipping_address => customer_shipping_address,
              :fraud_score => order_fraud_score,
              :payment_information => payment_information
          }
        end
      else
        magento_channel.custom_logging("Unable to get store id for code: #{magento_channel.connection_3}")
        puts "Unable to get store id for code #{magento_channel.connection_3}"
      end

      magento_channel.custom_logging("#{CustomLogger::FINISHED_DOWNLOADING} #{magento_channel.name}")

      if orders_to_process.count > 0
        magento_channel.custom_logging("Importing #{orders_to_process.count} order(s) for: #{magento_channel.name}")
        order_data = ImportOrder.format_order(orders_to_process)
        result = ImportOrder.process_import_file(order_data, magento_channel.company_id)
        if result[:message].blank?
          update_channel = true
          magento_channel.custom_logging("Imported #{orders_to_process.count} order(s) for: #{magento_channel.name}")
        else
          magento_channel.custom_logging("Error importing orders for: #{magento_channel.name}, the error is #{result[:message]}")
        end
      else
        update_channel = true
        magento_channel.custom_logging("#{CustomLogger::NO_NEW_ORDERS} #{magento_channel.name}")
      end

      magento_channel.custom_logging(CustomLogger::LINE_BREAK)
    end

    if update_channel
      Channel.find_all_by_system_channel_id(system_channel.id).each do |magento_channel|
        magento_channel.channel_updated_now("ORDER", process_start)
      end
    end
  end


  desc "Update Fraud Info"
  task :update_fraud_info => :environment do
    system_channel = SystemChannel.find_by_name("MAGENTO")
    Channel.find_all_by_system_channel_id(system_channel.id).each do |magento_channel|
      @orders = Order.where("created_at >= ?", 3.hours.ago).where(:channel_id => magento_channel.id)
      @orders.each do |order|
        Rails.logger.info("Checking fraud information for #{order.channel_order_id}")
        http = Net::HTTP.new(magento_channel.connection_1, 80)
        response = http.request(Net::HTTP::Get.new("/scripts/fraud_enq.php?order_id=#{order.channel_order_id}&format=json"))
        result = JSON.parse(response.body)
        if result.present?
          order_fraud_score = OrderFraudScore.find_or_create_by_order_id(order.id)
          order_fraud_score.last_four_digits = result["fraud_score"]["last_four_digits"]
          order_fraud_score.avscv2 = result["fraud_score"]["avscv2"]
          order_fraud_score.address_result = result["fraud_score"]["address_result"]
          order_fraud_score.postcode_result = result["fraud_score"]["postcode_result"]
          order_fraud_score.cv2result = result["fraud_score"]["cv2result"]
          order_fraud_score.threed_secure_status = result["fraud_score"]["threed_secure_status"]
          order_fraud_score.thirdman_action = result["fraud_score"]["thirdman_action"]
          order_fraud_score.thirdman_score = result["fraud_score"]["thirdman_score"].to_i
          order_fraud_score.save!
        end
      end
    end
  end

end
