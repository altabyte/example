class ShipOrderJob

  def perform
    begin
      channels_with_updates = Order.select("channels.id").joins(:channel).where(:status => Order::STATUS_DISPATCHED).group("channels.id")

      channels_with_updates.each do |channel_id|
        amazon_orders = []
        magneto_orders = []
        ebay_orders = []
        unknown_orders = []

        orders_to_update = Order.find_all_by_status_and_channel_shipping_id_and_channel_id(Order::STATUS_DISPATCHED, nil, channel_id)

        orders_to_update.each do |order|
          case order.channel.system_channel.name
            when "MAGENTO"
              magneto_orders << order
            when "AMAZON"
              amazon_orders << order
            when "EBAY"
              ebay_orders << order
            else
              unknown_orders << order
          end

        end
        process_magneto_orders(magneto_orders) if magneto_orders.count > 0
        process_amazon_orders(amazon_orders) if amazon_orders.count > 0
        process_ebay_orders(ebay_orders) if ebay_orders.count > 0
        if unknown_orders.count > 0
          raise "UNKNOWN SYSTEM CHANNEL ORDERS EXISTS - UNABLE TO SHIP TO PROCESS #{unknown_orders.count}"
        end
      end

    rescue => ex
      Rollbar.error(ex, :error_message => 'Error processing shipments > channels')
    end

  end


  def process_magneto_orders(orders)

    magneto_channel = orders[0].channel

    Magento::Base.connection = Magento::Connection.new(
        {
            :username => magneto_channel.connection_2,
            :api_key => Channel.decrypt(:password_1, magneto_channel.password_1_encrypted),
            :host => magneto_channel.connection_1,
            :path => '/api/xmlrpc',
            :port => '80'
        }
    )

    orders.each do |order|
      begin

        qty_array = Hash.new

        order.order_details.each do |item|
          qty_array[item.channel_order_detail_id] = item.quantity_picked.to_s
        end

        if order.original_order_id.present?
          order_id = Order.find_by_id(order.original_order_id).channel_order_id
        else
          order_id = order.channel_order_id
        end

        if order.complete?
          comment = SystemSetting.check_setting('magento_full_shipment_comment', nil, order.company_id)
        else
          comment = SystemSetting.check_setting('magento_part_shipment_comment', nil, order.company_id)
        end

        shipment_id = Magento::Shipment.create(order_id, qty_array, comment, true, (comment.present? ? true : false), order.actual_shipping_service.shipping_method.tracking_information, order.actual_shipping_service.shipping_method.name, order.tracking_details)
        if shipment_id.present?
          order.channel_shipping_id = shipment_id.increment_id
          order.save
          order.update_status(Order::STATUS_COMPLETE)
        end
      rescue => exc
        OrderError.find_or_create_by_order_id_and_process(order.id, 'SHIPPING', :error => exc.to_s)
        order.update_status(Order::STATUS_COMPLETE_WITH_ERROR)
      end
    end
  end


  def process_amazon_orders(orders)

    begin
      require 'mws-connect'
      require 'nokogiri'

      amazon_channel = orders[0].channel
      process_start = DateTime.now - 10.minutes

      mws = Mws.connect(
          merchant: amazon_channel.connection_1,
          access: amazon_channel.password_1,
          secret: amazon_channel.password_2,
          host: "mws-eu.amazonservices.com"
      )


      order_xml = Nokogiri::XML::Builder.new(:encoding => 'UTF-8') do |xml|
        xml.AmazonEnvelope('xmlns:xsi' => 'http://www.w3.org/2001/XMLSchema-instance', 'xsi:noNamespaceSchemaLocation' => 'amznenvelope.xsd') {
          xml.Header {
            xml.DocumentVersion '1.01'
            xml.MerchantIdentifier amazon_channel.connection_2
          }
          xml.MessageType 'OrderFulfillment'
          orders.each_with_index do |order, index|
            xml.Message {
              xml.MessageID (index + 1)
              xml.OrderFulfillment {
                xml.AmazonOrderID order.channel_order_id
                xml.FulfillmentDate process_start.utc.iso8601
                xml.FulfillmentData {
                  xml.CarrierName order.actual_shipping_service.shipping_method.name
                  xml.ShippingMethod order.actual_shipping_service.name
                  xml.ShipperTrackingNumber order.tracking_details if order.tracking_details.present?
                }
                order.order_details.each do |item|
                  xml.Item {
                    xml.AmazonOrderItemCode item.channel_order_detail_id
                    xml.Quantity item.quantity_picked
                  }
                end

              }
            } if ((order.actual_shipping_service.tracked == 1 and order.tracking_details.present?) or order.actual_shipping_service.tracked != 1)
          end
        }
      end.to_xml

      File.open("amazon.xml", 'w') { |f| f.write(order_xml) }

      request = mws.feeds.submit order_xml, {feed_type: :order_fufillment}

      if request and request.id
        orders.each do |amazon_order|
          amazon_order.channel_shipping_id = request.id
          amazon_order.save
          amazon_order.update_status(Order::STATUS_COMPLETE)
        end
      end

    rescue => ex
      puts ex
      Rollbar.error(ex)
    end

  end

  def process_ebay_orders(orders)

    begin
      require 'nokogiri'

      ebay_channel = orders[0].channel
      process_start = DateTime.now.utc.iso8601

      orders.each_with_index do |order, index|
        order_xml = Nokogiri::XML::Builder.new(:encoding => 'UTF-8') do |xml|
          xml.CompleteSaleRequest('xmlns' => 'urn:ebay:apis:eBLBaseComponents') {
            xml.RequesterCredentials {
              xml.eBayAuthToken ebay_channel.connection_1
            }
            xml.OrderID order.channel_order_id
            xml.Shipped true
            xml.Shipment {
              xml.ShippedTime process_start
              xml.ShipmentTrackingDetails {
                xml.ShipmentTrackingNumber order.tracking_details if order.tracking_details.present?
                xml.ShippingCarrierUsed order.actual_shipping_service.shipping_method.name
              } if (order.actual_shipping_service.tracked == 1 and order.tracking_details.present?)
            }
          }
        end.to_xml


        File.open("ebay.xml", 'w') { |f| f.write(order_xml) }

        begin
          headers = {
              'X-EBAY-API-COMPATIBILITY-LEVEL' => "837",
              'X-EBAY-API-CALL-NAME' => 'CompleteSale',
              'X-EBAY-API-SITEID' => ebay_channel.connection_2,
              'Content-Type' => 'text/xml'
          }

          sandbox = ebay_channel.connection_3 == 'SANDBOX'
          uri_prefix = "https://api#{sandbox ? ".sandbox" : ""}.ebay.com/ws"

          @uri = URI::parse("#{uri_prefix}/api.dll")


          http = Net::HTTP.new(@uri.host, @uri.port)
          http.read_timeout = 60

          if @uri.port == 443
            http.use_ssl = true
            http.verify_mode = OpenSSL::SSL::VERIFY_NONE
          end

          post = Net::HTTP::Post.new(@uri.path, headers)
          post.body = order_xml

          response = http.start { |http| http.request(post) }

          body = response.body if response
          hash = Hash.from_xml(body) if body
          response_data = hash["CompleteSaleResponse"] if hash

          if response_data['Ack'] == 'Success'
            order.save
            order.update_status(Order::STATUS_COMPLETE)
          else
            OrderError.find_or_create_by_order_id_and_process(order.id, 'SHIPPING', :error => response_data['Errors']['ShortMessage'])
            order.update_status(Order::STATUS_COMPLETE_WITH_ERROR)
          end

        rescue => exc
          OrderError.find_or_create_by_order_id_and_process(order.id, 'SHIPPING', :error => exc.to_s)
          order.update_status(Order::STATUS_COMPLETE_WITH_ERROR)
        end
      end
    rescue => ex
      Rollbar.error(ex)
    end

  end

end