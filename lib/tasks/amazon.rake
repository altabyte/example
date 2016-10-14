require 'rexml/document'

namespace :amazon do
  desc "Download Orders"
  task :download_orders => :environment do

    begin
      process_start = DateTime.now()
      system_channel = SystemChannel.find_by_name("AMAZON")
      Channel.find_all_by_system_channel_id(system_channel.id).each do |amazon_channel|

        service = Peddler::Orders.new amazon_channel.connection_3.present? ? amazon_channel.connection_3 : 'UK'
        service.configure(:key => amazon_channel.password_1, :secret => amazon_channel.password_2, :seller => amazon_channel.connection_1)
        service.marketplace(amazon_channel.connection_3.present? ? amazon_channel.connection_3 : 'UK')


        if amazon_channel.channel_updated_at("ORDER").present?
          amazon_channel.custom_logging("Last updated at: #{amazon_channel.channel_updated_at("ORDER")}")


          if amazon_channel.channel_updated_at("ORDER")
            amazon_channel.custom_logging("Checking API for updated after #{amazon_channel.channel_updated_at("ORDER").utc.iso8601}")

            new_orders = service.get query: {
                                         'Action' => 'ListOrders',
                                         'LastUpdatedAfter' => (amazon_channel.channel_updated_at("ORDER") - 2.hours).utc.iso8601,
                                         'MarketplaceId.ID.1' => service.marketplace,
                                         'OrderStatus.Status.1' => "Unshipped",
                                         'OrderStatus.Status.2' => "PartiallyShipped",
                                         'OrderStatus.Status.3' => "Shipped",
                                         'OrderStatus.Status.4' => "Pending",
                                         'OrderStatus.Status.5' => "Canceled"
                                     }

          end

        else

          new_orders = service.get query: {
                                       'Action' => 'ListOrders',
                                       'LastUpdatedAfter' => 1.day.ago.utc.iso8601,
                                       'MarketplaceId.ID.1' => service.marketplace,
                                       'OrderStatus.Status.1' => "Unshipped",
                                       'OrderStatus.Status.2' => "PartiallyShipped",
                                       'OrderStatus.Status.3' => "Shipped",
                                       'OrderStatus.Status.4' => "Pending",
                                       'OrderStatus.Status.5' => "Canceled"
                                   }

        end

        if new_orders.present?

          orders_to_process = []
          amazon_channel.custom_logging("#{CustomLogger::DOWNLOADING_ORDERS} #{amazon_channel.name}")
          doc = REXML::Document.new(new_orders.body.to_s.force_encoding("UTF-8"))

          REXML::XPath.each(doc, '/ErrorResponse/Error') do |error|
            options = {}
            error.element_children.each { |node| options[node.name.downcase.to_sym] = node.text }
            raise Errors::ServerError.new(options)
          end

          doc.elements.each('ListOrdersResponse/ListOrdersResult/Orders/Order') do |order|
            amazon_channel.custom_logging("#{CustomLogger::PROCESSING_ORDER} #{amazon_channel.name}::#{order.elements['AmazonOrderId'].text}::#{order.elements['OrderStatus'].text}")
            if order.elements['OrderStatus'].text != 'Canceled' and order.elements['OrderStatus'].text != 'Pending' and order.elements['SalesChannel'].text != 'AmazonCheckout'

              amazon_order_id = order.elements['AmazonOrderId'].text

              if Order.find_by_channel_id_and_channel_order_id(amazon_channel.id, amazon_order_id).blank?

                customer = {
                    :full_name => (order.elements['ShippingAddress'].elements['Name'].text.to_s.upcase rescue nil),
                    :email => order.elements['BuyerEmail'].text
                }

                addr_line1 = (order.elements['ShippingAddress'].elements['AddressLine1'].text.to_s.titleize rescue nil)
                addr_line2 = (order.elements['ShippingAddress'].elements['AddressLine2'].text.to_s.titleize rescue nil)
                if addr_line1.blank? and addr_line2.present?
                  addr_line1 = addr_line2
                  addr_line2 = nil
                end

                customer_shipping_address = {
                    :name => (order.elements['ShippingAddress'].elements['Name'].text.to_s.upcase rescue nil),
                    :address_line_1 => (addr_line1 rescue nil),
                    :address_line_2 => (addr_line2 rescue nil),
                    :town => (order.elements['ShippingAddress'].elements['City'].text.to_s.titleize rescue nil),
                    :company => (order.elements['ShippingAddress'].elements['Company'].text.to_s.titleize rescue nil),
                    :county => (order.elements['ShippingAddress'].elements['StateOrRegion'].text.to_s.titleize rescue nil),
                    :country => (order.elements['ShippingAddress'].elements['CountryCode'].text.to_s.upcase rescue nil),
                    :post_code => (order.elements['ShippingAddress'].elements['PostalCode'].text.to_s.strip.upcase rescue nil),
                    :telephone => (order.elements['ShippingAddress'].elements['Phone'].text rescue nil)
                }

                amazon_order_items = service.get query: {
                                                     'Action' => 'ListOrderItems',
                                                     'AmazonOrderId' => amazon_order_id,
                                                 }

                shipping = 0

                order_items = []

                amz_order_items = REXML::Document.new(amazon_order_items.body.to_s.force_encoding("UTF-8"))
                amz_order_items.elements.each('ListOrderItemsResponse/ListOrderItemsResult/OrderItems/OrderItem') do |amazon_order_item|
                  order_items << {
                      :order_detail_id => amazon_order_item.elements['OrderItemId'].text,
                      :sku => amazon_order_item.elements['SellerSKU'].text,
                      :name => (amazon_order_item.elements['Title'].text rescue nil),
                      :qty_ordered => (amazon_order_item.elements['QuantityOrdered'].text rescue nil),
                      :unit_price => (ExchangeRate.convert(amazon_order_item.elements['ItemPrice'].elements['CurrencyCode'].text, amazon_order_item.elements['ItemPrice'].elements['Amount'].text, amazon_channel.company) rescue nil),
                      :gift_wrap_level => (amazon_order_item.elements['GiftWrapLevel'].text rescue nil),
                      :gift_wrap_price => (ExchangeRate.convert(amazon_order_item.elements['ItemPrice'].elements['CurrencyCode'].text, amazon_order_item.elements['GiftWrapPrice'].elements['Amount'].text, amazon_channel.company) rescue nil),
                      :gift_wrap_message => (amazon_order_item.elements['GiftMessageText'].text rescue nil),
                  }
                  if amazon_order_item.elements['ShippingPrice'].present?
                    shipping += (ExchangeRate.convert(amazon_order_item.elements['ShippingPrice'].elements['CurrencyCode'].text, amazon_order_item.elements['ShippingPrice'].elements['Amount'].text, amazon_channel.company).to_d rescue nil)
                  end
                end

                sub_total = (order.elements['OrderTotal'].elements['Amount'].text.to_d - shipping)

                payment_information=''
                payment_information = order.elements['PaymentMethod'].text if order.elements['PaymentMethod'].present?

                orders_to_process << {
                    :channel_id => amazon_channel.id,
                    :channel_name => amazon_channel.name,
                    :order_id => amazon_order_id,
                    :shipping_service => order.elements['ShipServiceLevel'].text,
                    :order_date => order.elements['PurchaseDate'].text,
                    :order_status => order.elements['OrderStatus'].text,
                    :order_total => ExchangeRate.convert(order.elements['OrderTotal'].elements['CurrencyCode'].text, order.elements['OrderTotal'].elements['Amount'].text, amazon_channel.company),
                    :shipping_cost => shipping,
                    :order_items => order_items,
                    :customer => customer,
                    :shipping_address => customer_shipping_address,
                    :sub_total => sub_total,
                    :payment_information => payment_information
                }

              end


            elsif order.elements['OrderStatus'].text == 'Canceled'

              orders = Order.find_or_initialize_by_channel_id_and_channel_order_id(amazon_channel.id, order.elements['AmazonOrderId'].text)
              if orders.present?
                orders.status = Order::STATUS_CANCELLED
                orders.company_id = amazon_channel.company_id
                orders.save
              end

            else

              #TODO PENDING ORDER HERE
              #The following response elements are not available for orders with an OrderStatus of Pending but are available
              #for orders with an OrderStatus of Unshipped, Partially Shipped, or Shipped:
              #• OrderTotal
              #• BuyerEmail
              #• BuyerName
              #• ShippingAddress

            end
          end

          amazon_channel.custom_logging("#{CustomLogger::FINISHED_DOWNLOADING} #{amazon_channel.name}")

          if orders_to_process.count > 0
            amazon_channel.custom_logging("Importing #{orders_to_process.count} order(s) for: #{amazon_channel.name}")
            order_data = ImportOrder.format_order(orders_to_process)
            result = ImportOrder.process_import_file(order_data, amazon_channel.company_id)
            if result[:message].blank?
              Channel.find_all_by_system_channel_id(system_channel.id).each do |amazon_channel|
                amazon_channel.channel_updated_now("ORDER", process_start)
              end
            else
              amazon_channel.custom_logging("Error importing orders for: #{amazon_channel.name}, the error is #{result[:message]}")
            end
          else
            amazon_channel.custom_logging("#{CustomLogger::NO_NEW_ORDERS} #{amazon_channel.name}")
            amazon_channel.channel_updated_now("ORDER", process_start)
          end
        else
          amazon_channel.custom_logging("Trying to update Amazon within 10 minutes of last run")
        end
        amazon_channel.custom_logging(CustomLogger::LINE_BREAK)
      end
    rescue => ex
      Rails.logger.error(ex)
      Rollbar.error(ex)
    end
  end
end
