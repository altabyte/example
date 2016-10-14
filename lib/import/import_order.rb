require 'rexml/document'

module ImportOrder
  def self.process_import_file(data, company_id=nil)

    export_file_name = self.export_import_data(data)

    doc = REXML::Document.new(data)
    order_count = 0
    order_successful_count = 0
    message = ''

    doc.elements.each('Orders/Order') do |order|
      begin
        order_processed = self.process_order(order, company_id)
        order_successful_count += 1 if order_processed
        order_count += 1
      rescue => exc
        message = "Failed with error #{exc.to_s}"
        Rails.logger.info("#{exc.to_s}. Import Error, File Name=#{export_file_name}")
        Rollbar.error(exc, :error_message => "Import Error, File Name=#{export_file_name}", :order_data => order)
      end
      break if message.present?
    end

    {:success => order_successful_count, :failed => (order_count - order_successful_count), :message => message}
  end

  def self.process_order(order_data, company_id)

    if order_data.attributes['ChannelID'].present?
      channel = Channel.find(order_data.attributes['ChannelID'].to_s)
    elsif company_id.present? and order_data.attributes['ChannelName'].present?
      channel = Channel.find_by_name_and_company_id(order_data.attributes['ChannelName'].to_s, company_id)
    end

    if channel.present?
      channel_status = ChannelStatus.find_by_status_name_and_channel_id(order_data.elements['OrderStatus'].text, channel.id)
      if channel_status.present? and channel_status.status.present?
        order = Order.find_or_initialize_by_channel_id_and_channel_order_id(channel.id, order_data.elements['OrderID'].text)

        if order.order_status_histories.blank?
          customer = self.process_customer(channel, order_data.elements['Customer']) if order_data.elements['Customer'].present?
          billing_address = self.process_customer_address('BILLING', customer, order_data.elements['BillingAddress']) if order_data.elements['BillingAddress'].present?
          shipping_address = self.process_customer_address('SHIPPING', customer, order_data.elements['ShippingAddress']) if order_data.elements['ShippingAddress'].present?

          order.customer_id = customer.id
          order.order_date = order_data.elements['OrderDate'].text

          order.status = channel_status.status
          order.order_total = order_data.elements['OrderTotal'].text.to_d
          order.shipping_cost = order_data.elements['OrderShippingCost'].text.to_d
          order.subtotal = order_data.elements['OrderSubTotal'].text.to_d rescue 0
          order.vat_amount = order_data.elements['OrderVatAmount'].text.to_d rescue 0
          order.payment_information = order_data.elements['PaymentInformation'].text.to_s.upcase rescue ''
          order.shipping_address_id = shipping_address.id rescue nil
          order.billing_address_id = billing_address.id rescue nil
          order.company_id = channel.company_id
          order.order_xml = order_data.to_s
          order.save!

          skus = order_data.elements.each('OrderItems/OrderItem') do |order_item|
            self.process_order_item(order, order_item)
          end

          shipping_service = ChannelShippingService.check_shipping_method(order_data.elements['ShippingService'].text, order.order_total, skus, channel.id)
          order.channel_shipping_service_id = shipping_service.id
          order.save!

          self.process_fraud_score(order, order_data.elements['FraudScore']) if order_data.elements['FraudScore'].present?

          self.export_order_to_xml(order, order_data) if channel.export_order
        end
      else
        ChannelStatus.create(:status_name => order_data.elements['OrderStatus'].text, :channel_id => channel.id)
        payload = format_pending_payload(order_data)
        PendingOrder.create(:order_payload => payload, :company_id => company_id, :reason_pending => 'UNABLE TO MATCH CHANNEL STATUS', :channel_id => channel.id)
        return false
      end
    else
      payload = format_pending_payload(order_data)
      PendingOrder.create(:order_payload => payload, :company_id => company_id, :reason_pending => 'CHANNEL MISSING')
      return false
    end
    return true
  end

  def self.process_customer(channel, customer_data)
    customer = Customer.find_or_initialize_by_channel_id_and_email_and_company_id(channel.id, customer_data.elements['email'].text.downcase, channel.company_id)
    customer.full_name = customer_data.elements['FullName'].text
    customer.save!
    customer
  end

  def self.process_customer_address(address_type, customer, address)
    if address.attributes['AddressID'].present?
      customer_address = CustomerAddress.find_or_initialize_by_channel_address_id_and_customer_id_and_address_type(address.attributes['AddressID'].to_s, customer.id, address_type)
    else
      customer_address = CustomerAddress.find_or_initialize_by_customer_id_and_address_type(customer.id, address_type)
    end

    if address_type == 'SHIPPING'
      if address.elements['Name'].present?
        customer_name = address.elements['Name'].text.to_s
      else
        customer_name = customer.full_name
      end
    else
      customer_name = customer.full_name
    end

    customer_address.name = customer_name
    customer_address.address_1 = address.elements['AddressLine1'].text.to_s.titlecase
    customer_address.address_2 = address.elements['AddressLine2'].text.to_s.titlecase
    customer_address.town = address.elements['Town'].text.to_s.upcase
    customer_address.company = address.elements['Company'].text.to_s.upcase
    customer_address.county = address.elements['County'].text.to_s.upcase
    if Country.find_country_by_alpha2(address.elements['Country'].text.to_s.upcase).present?
      country = address.elements['Country'].text.to_s.upcase
    else
      country = (Country.find_country_by_name(address.elements['Country'].text.to_s.upcase).alpha2 rescue '')
    end
    customer_address.country = country
    customer_address.post_code = address.elements['PostCode'].text.to_s.upcase
    customer_address.telephone = (address.elements['Telephone'].text.to_s.gsub(/[^0-9]/, '').upcase rescue '')
    customer_address.save!
    customer_address
  end


  def self.process_order_item(order, order_item)
    #find or create product
    item = Item.find_or_initialize_by_sku_and_company_id(order_item.elements['SKU'].text, order.channel.company_id)
    item.name = order_item.elements['ItemName'].text
    item.colour = order_item.elements['Colour'].text rescue nil
    item.size = order_item.elements['Size'].text rescue nil
    item.harmonization_code = order_item.elements['HarmonizationCode'].text rescue nil
    item.country_code = order_item.elements['CountyOfOrigin'].text rescue nil
    item.item_weight = order_item.elements['ItemWeight'].text.to_d rescue nil
    item.save!

    order_detail = OrderDetail.find_or_initialize_by_order_id_and_channel_order_detail_id(order.id, order_item.attributes['OrderDetailID'].to_s)
    order_detail.item_id = item.id
    order_detail.quantity_ordered = order_item.elements['QtyOrdered'].text
    order_detail.unit_price = order_item.elements['UnitPrice'].text
    order_detail.vat_amount = order_item.elements['VatAmount'].text
    order_detail.save!
    [order_detail.item.sku, order_detail.unit_price]
  end

  def self.process_fraud_score(order, fraud_score)
    order_fraud_score = OrderFraudScore.find_or_create_by_order_id(order.id)
    order_fraud_score.last_four_digits = fraud_score.elements['LastFourDigits'].text rescue nil
    order_fraud_score.avscv2 = fraud_score.elements['AVSCV2'].text rescue nil
    order_fraud_score.address_result = fraud_score.elements['AddressResult'].text rescue nil
    order_fraud_score.postcode_result = fraud_score.elements['PostcodeResult'].text rescue nil
    order_fraud_score.cv2result = fraud_score.elements['CV2Result'].text rescue nil
    order_fraud_score.threed_secure_status = fraud_score.elements['ThreedSecureStatus'].text rescue nil
    order_fraud_score.thirdman_action = fraud_score.elements['ThirdmanAction'].text rescue nil
    order_fraud_score.thirdman_score = fraud_score.elements['ThirdmanScore'].text.to_i rescue nil
    order_fraud_score.save!
    order_fraud_score
  end

  def self.export_order_to_xml(order, order_xml)
    client_share = order.channel.company.client_share

    if client_share.present?
      require 'fileutils'
      file_path = Rails.root.join('export', client_share, 'orders')
      FileUtils.mkpath(file_path)

      unless File.exist?(file_path + "order_#{order.id}.xml")
        File.open(file_path + "order_#{order.id}.xml", "w") { |f| f << order_xml }
      end
    end
  end

  def self.export_import_data(data)
    file_name = "#{Time.now.strftime("%Y-%m-%d-%H%M%S")}.xml"
    require 'fileutils'
    file_path = Rails.root.join('export', 'import_data')
    FileUtils.mkpath(file_path)

    unless File.exist?(file_path + "order_output_#{file_name}")
      File.open(file_path + "order_output_#{file_name}", "w") { |f| f << data }
    end
    file_name
  end

  def self.format_pending_payload(order)
    builder = Nokogiri::XML::Builder.new do |xml|
      xml.Orders {
        xml << order.to_s
      }
    end
    builder.to_xml
  end

  def self.format_order(orders_to_process)
    builder = Nokogiri::XML::Builder.new do |xml|
      xml.Orders {

        orders_to_process.each do |order|

          xml.Order(ChannelID: order[:channel_id], ChannelName: order[:channel_name]) {
            xml.OrderID order[:order_id]
            xml.ShippingService order[:shipping_service]
            xml.OrderDate order[:order_date]
            xml.OrderStatus order[:order_status]
            xml.OrderTotal order[:order_total]
            xml.OrderSubTotal order[:sub_total]
            xml.OrderShippingCost order[:shipping_cost]
            xml.OrderVatAmount order[:vat_amount]
            xml.PaymentInformation order[:payment_information]

            xml.Customer {
              xml.FullName order[:customer][:full_name]
              xml.email order[:customer][:email]
            }

            address = order[:shipping_address]

            xml.ShippingAddress(AddressID: address[:address_id]) {
              xml.Name address[:name]
              xml.AddressLine1 address[:address_line_1]
              xml.AddressLine2 address[:address_line_2]
              xml.Town address[:town]
              xml.Company address[:company]
              xml.County address[:county]
              xml.Country address[:country]
              xml.PostCode address[:post_code]
              xml.Telephone address[:telephone]
            } unless address.blank?

            address = order[:billing_address]

            xml.BillingAddress(AddressID: address[:address_id]) {
              xml.AddressLine1 address[:address_line_1]
              xml.AddressLine2 address[:address_line_2]
              xml.Town address[:town]
              xml.Company address[:company]
              xml.County address[:county]
              xml.Country address[:country]
              xml.PostCode address[:post_code]
              xml.Telephone address[:telephone]
            } unless address.blank?


            xml.OrderItems {
              order[:order_items].each do |order_item|
                xml.OrderItem(OrderDetailID: order_item[:order_detail_id]) {
                  xml.SKU order_item[:sku]
                  xml.ItemName order_item[:name]
                  xml.Colour order_item[:colour]
                  xml.Size order_item[:size]
                  xml.QtyOrdered order_item[:qty_ordered]
                  xml.UnitPrice order_item[:unit_price]
                  xml.VatAmount order_item[:vat_amount]
                  xml.HarmonizationCode order_item[:harmonization_code]
                  xml.CountyOfOrigin order_item[:country_of_origin]
                  xml.ItemWeight order_item[:item_weight]
                  xml.GiftWrapLevel order_item[:gift_wrap_level]
                  xml.GiftWrapPrice order_item[:gift_wrap_price]
                  xml.GiftWrapMessage order_item[:gift_wrap_message]
                }
              end
            }

            if order[:fraud_score].present?
              xml.FraudScore {
                xml.LastFourDigits order[:fraud_score][:last_four_digits]
                xml.AVSCV2 order[:fraud_score][:avscv2]
                xml.AddressResult order[:fraud_score][:address_result]
                xml.PostcodeResult order[:fraud_score][:postcode_result]
                xml.CV2Result order[:fraud_score][:cv2result]
                xml.ThreedSecureStatus order[:fraud_score][:threed_secure_status]
                xml.ThirdmanAction order[:fraud_score][:thirdman_action]
                xml.ThirdmanScore order[:fraud_score][:thirdman_score]
              }
            end
          }
        end
      }
    end
    builder.to_xml
  end

end