require 'rexml/document'

namespace :ebay do
  desc "Download Orders"
  task :download_orders => :environment do

    require 'ebayr'

    begin
      process_start = DateTime.now()
      system_channel = SystemChannel.find_by_name("EBAY")
      Channel.find_all_by_system_channel_id(system_channel.id).each do |channel|
        orders_to_process = []

        if channel.channel_updated_at("ORDER").present?
          channel.custom_logging("Last updated at: #{channel.channel_updated_at("ORDER")}")
          channel.custom_logging("Checking API for updated after #{channel.channel_updated_at("ORDER")}")
          from_dt = channel.channel_updated_at("ORDER")
        else
          from_dt = 30.day.ago
        end
        response = Ebayr.call(:GetOrders, :auth_token => channel.connection_1, :site_id => channel.connection_2, :OrderStatus => 'All', :ModTimeFrom => from_dt, :OrderRole => 'Seller')

        if response[:ack] == 'Success'
          if response[:order_array].present?
            new_orders = response[:order_array][:order]
            new_orders.each_with_index do |new_order, index|

              if new_order[:checkout_status][:status] == 'Complete'

                channel.custom_logging("#{CustomLogger::PROCESSING_ORDER} #{channel.name}::#{new_order[:order_id]}::#{new_order[:OrderStatus]}")
                shipping_address = new_order[:shipping_address]

                if new_order[:transaction_array][:transaction].is_a?(Array)
                  email = new_order[:transaction_array][:transaction][0][:buyer][:email]
                else
                  email = new_order[:transaction_array][:transaction][:buyer][:email]
                end

                customer = {
                    :full_name => (shipping_address[:name].upcase rescue nil),
                    :email => email
                }

                addr_line1 = (shipping_address[:street1].to_s.titleize rescue nil)
                addr_line2 = (shipping_address[:street2].to_s.titleize rescue nil)
                if addr_line1.blank? and addr_line2.present?
                  addr_line1 = addr_line2
                  addr_line2 = nil
                end

                customer_shipping_address = {
                    :name => (shipping_address[:name].to_s.upcase rescue nil),
                    :address_line_1 => (addr_line1 rescue nil),
                    :address_line_2 => (addr_line2 rescue nil),
                    :town => (shipping_address[:city_name].to_s.titleize rescue nil),
                    :company => (shipping_address[:street_1].to_s.titleize rescue nil),
                    :county => (shipping_address[:state_or_province].to_s.titleize rescue nil),
                    :country => (shipping_address[:country].to_s.upcase rescue nil),
                    :post_code => (shipping_address[:postal_code].to_s.strip.upcase rescue nil),
                    :telephone => (shipping_address[:phone] rescue nil)
                }


                order_items = []

                if new_order[:transaction_array][:transaction].is_a?(Array)
                  new_order[:transaction_array][:transaction].each do |transaction_item|
                    item = transaction_item[:item]
                    sku = item[:sku].present? ? item[:sku] : item[:item_id]
                    order_items << {
                        :order_detail_id => transaction_item[:order_line_item_id],
                        :sku => sku,
                        :name => (item[:title] rescue nil),
                        :qty_ordered => (transaction_item[:quantity_purchased].to_i rescue 1),
                        :unit_price => (transaction_item[:transaction_price].to_d rescue nil)
                    }

                  end
                else

                  transaction = new_order[:transaction_array][:transaction]

                  item = transaction[:item]
                  sku = item[:sku].present? ? item[:sku] : item[:item_id]

                  order_items << {
                      :order_detail_id => transaction[:order_line_item_id],
                      :sku => sku,
                      :name => (item[:title] rescue nil),
                      :qty_ordered => (transaction[:quantity_purchased].to_i rescue 1),
                      :unit_price => (transaction[:transaction_price].to_d rescue nil)
                  }

                end

                shipping = (new_order[:shipping_details][:shipping_service_options][:shipping_service_cost].to_d rescue 0)

                sub_total = (new_order[:subtotal].to_d)

                payment_information=''
                payment_information = new_order[:payment_methods] if new_order[:payment_methods].present?

                orders_to_process << {
                    :channel_id => channel.id,
                    :channel_name => channel.name,
                    :order_id => new_order[:order_id],
                    :shipping_service => new_order[:shipping_details][:shipping_service_options][:shipping_service],
                    :order_date => new_order[:created_time],
                    :order_status => new_order[:order_status],
                    :order_total => new_order[:total],
                    :shipping_cost => shipping,
                    :order_items => order_items,
                    :customer => customer,
                    :shipping_address => customer_shipping_address,
                    :sub_total => sub_total,
                    :payment_information => payment_information
                }

              end
            end

            channel.custom_logging("#{CustomLogger::FINISHED_DOWNLOADING} #{channel.name}")

            if orders_to_process.count > 0
              channel.custom_logging("Importing #{orders_to_process.count} order(s) for: #{channel.name}")
              order_data = ImportOrder.format_order(orders_to_process)
              result = ImportOrder.process_import_file(order_data, channel.company_id)
              if result[:message].blank?
                Channel.find_all_by_system_channel_id(system_channel.id).each do |up_channel|
                  up_channel.channel_updated_now("ORDER", process_start)
                end
              else
                channel.custom_logging("Error importing orders for: #{channel.name}, the error is #{result[:message]}")
              end
            else
              channel.custom_logging("#{CustomLogger::NO_NEW_ORDERS} #{channel.name}")
              Channel.find_all_by_system_channel_id(system_channel.id).each do |up_channel|
                up_channel.channel_updated_now("ORDER", process_start)
              end
            end
          else
            channel.custom_logging("#{CustomLogger::NO_NEW_ORDERS} #{channel.name}")
            Channel.find_all_by_system_channel_id(system_channel.id).each do |up_channel|
              up_channel.channel_updated_now("ORDER", process_start)
            end
          end
        else
          channel.custom_logging("Error getting orders: #{response.errors.to_s}")
          raise "Error getting orders: #{response.errors.to_s}"
        end
        channel.custom_logging(CustomLogger::LINE_BREAK)
      end


    rescue => ex
      Rails.logger.error(ex)
      Rollbar.error(ex)
    end


    def successful_ebay_response(response)
      @ack_response = response.ack
      @ack_response === 'Success' || @ack_response === 'Warning'
    end

  end
end
