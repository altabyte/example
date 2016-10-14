class VerifyAmazonOrdersJob

  def perform
    system_channel = SystemChannel.find_by_name("AMAZON")
    Channel.find_all_by_system_channel_id(system_channel.id).each do |amazon_channel|
      #begin
      mws = Mws.connect(
          merchant: amazon_channel.connection_1,
          access: amazon_channel.password_1,
          secret: amazon_channel.password_2,
          host: "mws-eu.amazonservices.com"
      )

      response = mws.post("/", {report_type: '_GET_FLAT_FILE_ORDERS_DATA_', start_date: 1.day.ago.utc.iso8601, report_options: 'ShowSalesChannel%3Dtrue'}, nil, {
                                 action: 'RequestReport',
                                 xpath: '///ReportRequestId',
                                 version: '2009-01-01'
                             })

      document_id = response.text rescue nil
      report_id = nil
      count = 0
      sleep (30)

      if document_id.present?
        begin
          report_response = mws.post("/", {report_request_id_list: [document_id]}, nil, {
                                            action: 'GetReportRequestList',
                                            version: '2009-01-01',
                                            list_pattern: '%{key}.Id.%<index>d'
                                        })

          if report_response.xpath('//GetReportRequestListResult//ReportRequestInfo//ReportProcessingStatus').text == '_CANCELLED_'
            break
          end

          report_id = report_response.xpath('//GetReportRequestListResult//ReportRequestInfo//GeneratedReportId').text rescue nil
          if report_id.present?
            break
          end
          count += 1
          sleep (60)
        end while report_id.blank? and count < 10
      end

      report = nil
      if report_id.present?
        report = mws.get_no_parse("/", {report_id: report_id}, {
                                         action: 'GetReport',
                                         xpath: 'AmazonEnvelope/Message',
                                         version: '2009-01-01'
                                     })
      end

      if report.present?

        report = report.force_encoding('ISO-8859-1').encode('UTF-8')

        export_data_path = Rails.root.join('export', amazon_channel.company.client_share, 'amazon_verification')
        FileUtils.mkpath(export_data_path)
        export_data_path = export_data_path +"amazon_verification_#{Time.now.strftime("%Y-%m-%d-%H%M%S")}.csv"
        File.open(export_data_path, 'w') { |f| f.write(report) }

        require 'csv'

        def process(csv_array) # makes arrays of hashes out of CSV's arrays of arrays
          result = []
          return result if csv_array.nil? || csv_array.empty?
          headerA = csv_array.shift # remove first array with headers from array returned by CSV
          headerA.map! { |x| x.downcase.gsub('-', '_').to_sym } # make symbols out of the CSV headers
          csv_array.each do |row| #    convert each data row into a hash, given the CSV headers
            result << Hash[headerA.zip(row)] #    you could use HashWithIndifferentAccess here instead of Hash
          end
          return result
        end

        missing_orders_array = []
        csv_data = process(CSV.parse(report, {:col_sep => "\t"}))
        csv_data.each do |csv_row|
          if csv_row[:sales_channel].blank?
            orders = Order.find_by_channel_order_id_and_channel_id(csv_row[:order_id], amazon_channel.id)
            unless orders.present?
              missing_orders_array << csv_row[:order_id]
            end
          end
        end

        if missing_orders_array.count > 0

          Rails.logger.info "Downloading Missing Order For: #{amazon_channel.name}, #{missing_orders_array}"
          service = Peddler::Orders.new amazon_channel.connection_3.present? ? amazon_channel.connection_3 : 'UK'
          service.configure(:key => amazon_channel.password_1, :secret => amazon_channel.password_2, :seller => amazon_channel.connection_1)
          service.marketplace(amazon_channel.connection_3.present? ? amazon_channel.connection_3 : 'UK')

          query = {'Action' => 'GetOrder'}

          missing_orders_array.each_with_index do |order, index|
            query["AmazonOrderId.Id.#{index + 1}"] = order
            if index > 49
              break
            end
          end

          Rails.logger.info "Query being posted to Amazon: #{query}"

          missing_orders = service.get query: query

          if missing_orders.present?

            doc = REXML::Document.new(missing_orders.body.to_s.force_encoding("UTF-8"))

            REXML::XPath.each(doc, '/ErrorResponse/Error') do |error|
              options = {}
              error.element_children.each { |node| options[node.name.downcase.to_sym] = node.text }
              raise Errors::ServerError.new(options)
            end

            doc.elements.each('GetOrderResponse/GetOrderResult/Orders/Order') do |order|
              Rails.logger.info "Processing Order #{amazon_channel.name}::#{order.elements['AmazonOrderId'].text}::#{order.elements['OrderStatus'].text}"


              if (order.elements['OrderStatus'].text != 'Canceled' and order.elements['OrderStatus'].text != 'Pending') and order.elements['SalesChannel'].text != 'AmazonCheckout'

                #customers
                customer = Customer.find_or_initialize_by_email_and_channel_id_and_company_id(order.elements['BuyerEmail'].text, amazon_channel.id, amazon_channel.company_id)

                #TODO customer name
                customer.phone_number = order.elements['ShippingAddress'].elements['Phone'].text rescue nil
                customer.full_name = order.elements['BuyerName'].text rescue nil
                customer.save

                #amazon only supplies 1 address (order header:: both address are set to this)
                address_type = "SHIPPING"
                shipping_address = CustomerAddress.find_or_initialize_by_customer_id(customer.id)
                shipping_address.address_type = address_type
                shipping_address.address_1 = order.elements['ShippingAddress'].elements['AddressLine1'].text rescue nil
                shipping_address.address_2 = order.elements['ShippingAddress'].elements['AddressLine2'].text rescue nil
                shipping_address.town = order.elements['ShippingAddress'].elements['City'].text rescue nil
                shipping_address.county = order.elements['ShippingAddress'].elements['StateOrRegion'].text rescue nil
                shipping_address.post_code = order.elements['ShippingAddress'].elements['PostalCode'].text rescue nil
                shipping_address.country = order.elements['ShippingAddress'].elements['CountryCode'].text rescue nil
                shipping_address.telephone = order.elements['ShippingAddress'].elements['Phone'].text rescue nil
                shipping_address.name = order.elements['ShippingAddress'].elements['Name'].text rescue nil
                shipping_address.save

                #Order
                orders = Order.find_or_initialize_by_channel_id_and_channel_order_id(amazon_channel.id, order.elements['AmazonOrderId'].text)
                orders.customer_id = customer.id
                orders.order_date = order.elements['PurchaseDate'].text
                channel_status = ChannelStatus.find_or_create_by_status_name_and_channel_id(order.elements['OrderStatus'].text, amazon_channel.id)
                orders.status = channel_status.status
                orders.order_total = order.elements['OrderTotal'].elements['Amount'].text
                orders.shipping_address_id = shipping_address.id
                orders.billing_address_id = shipping_address.id
                orders.order_xml = order.to_s
                orders.company_id = amazon_channel.company_id
                orders.save


                amazon_order_items = service.get query: {
                                                     'Action' => 'ListOrderItems',
                                                     'AmazonOrderId' => orders.channel_order_id,
                                                 }

                skus = []
                shipping = 0

                order_items = REXML::Document.new(amazon_order_items.body.to_s.force_encoding("UTF-8"))

                order_items.elements.each('ListOrderItemsResponse/ListOrderItemsResult/OrderItems/OrderItem') do |amazon_order_item|

                  item = Item.find_or_initialize_by_sku_and_company_id(amazon_order_item.elements['SellerSKU'].text, amazon_channel.company_id)
                  if item.new_record?
                    item.name = amazon_order_item.elements['Title'].text rescue nil
                    #  item.colour = product_colour["label"]
                    #  item.size = product_size["label"]
                    item.save
                  end

                  order_item = OrderDetail.find_or_initialize_by_order_id_and_channel_order_detail_id(orders.id, amazon_order_item.elements['OrderItemId'].text)
                  order_item.item_id = item.id
                  order_item.quantity_ordered = amazon_order_item.elements['QuantityOrdered'].text rescue nil
                  order_item.unit_price = amazon_order_item.elements['ItemPrice'].elements['Amount'].text rescue nil
                  order_item.gift_wrap_level = amazon_order_item.elements['GiftWrapLevel'].text rescue nil
                  order_item.gift_wrap_price = amazon_order_item.elements['GiftWrapPrice'].elements['Amount'].text rescue nil
                  order_item.gift_wrap_message = amazon_order_item.elements['GiftMessageText'].text rescue nil
                  skus << [item.sku, order_item.unit_price]
                  shipping += (amazon_order_item.elements['ShippingPrice'].elements['Amount'].text).to_d rescue nil
                  order_item.save

                end

                orders.shipping_cost = shipping

                #find or create shipping service
                amazon_shipping_service = order.elements['ShipServiceLevel'].text rescue nil
                shipping_service = ChannelShippingService.check_shipping_method(amazon_shipping_service, orders.order_total, skus, amazon_channel.id)
                orders.channel_shipping_service_id = shipping_service.id
                orders.save

                #export
                Order.export_order_to_xml(orders.id)

              elsif order.elements['OrderStatus'].text == 'Canceled' and order.elements['SalesChannel'].text != 'AmazonCheckout'

                orders = Order.find_or_initialize_by_channel_id_and_channel_order_id(amazon_channel.id, order.elements['AmazonOrderId'].text)
                if orders.present?
                  orders.status = Order::STATUS_CANCELLED
                  orders.save
                  orders.company_id = amazon_channel.company_id
                end
              end
            end
          end
        end
      end
      #rescue => ex
      #  Rollbar.error(ex)
      #end
    end
  end

  def max_attempts
    return 1
  end

end