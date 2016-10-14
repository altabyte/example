class AmazonInventoryFeedJob

  def perform
    begin
      require 'mws-connect'
      require 'nokogiri'
      system_channel = SystemChannel.find_by_name("AMAZON")
      amazon_channels = system_channel.channels.where(:inventory_feed => true)
      amazon_channels.each do |amazon_channel|
        update_amazon_reports
        get_amazon_asins(amazon_channel)
        feed = create_amazon_feed(amazon_channel)
        submit_amazon_feed(amazon_channel, feed) if feed.present?
        update_amazon_reports
      end

    rescue => ex
      Rollbar.error(ex)
    end
  end

  def get_amazon_asins(amazon_channel)
    begin
      mws = Mws.connect(
          merchant: amazon_channel.connection_1,
          access: amazon_channel.password_1,
          secret: amazon_channel.password_2,
          host: "mws-eu.amazonservices.com"
      )

      response = mws.post("/", {report_type: '_GET_FLAT_FILE_OPEN_LISTINGS_DATA_'}, nil, {
                                 action: 'RequestReport',
                                 xpath: '///ReportRequestId',
                                 version: '2009-01-01'
                             })

      document_id = response.text rescue nil
      report_id = nil
      count = 0

      if document_id.present?
        begin
          report_response = mws.post("/", {report_request_id_list: document_id}, nil, {
                                            action: 'GetReportList',
                                            xpath: '///ReportId',
                                            version: '2009-01-01'
                                        })
          report_id = report_response.text rescue nil
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
        File.open("amazon_inventory.csv", 'w') { |f| f.write(report) }
        require 'csv'

        def process(csv_array) # makes arrays of hashes out of CSV's arrays of arrays
          result = []
          return result if csv_array.nil? || csv_array.empty?
          headerA = csv_array.shift # remove first array with headers from array returned by CSV
          headerA.map! { |x| x.downcase.to_sym } # make symbols out of the CSV headers
          csv_array.each do |row| #    convert each data row into a hash, given the CSV headers
            result << Hash[headerA.zip(row)] #    you could use HashWithIndifferentAccess here instead of Hash
          end
          return result
        end

        csv_data = process(CSV.parse(report, {:col_sep => "\t"}))
        csv_data.each do |csv_row|
          if csv_row[:sku].present?
            item = Item.find_by_sku_and_company_id(csv_row[:sku], amazon_channel.company_id)
            if item.present?
              item.amazon_asin = csv_row[:asin]
              item.save
            end
          end
        end
      end
    rescue => ex
      Rollbar.error(ex)
    end
  end

  def update_amazon_reports
    begin
      require 'mws-connect'
      require 'nokogiri'

      amazon_reps = AmazonReport.where("payload is null")

      if amazon_reps.count > 0
        amazon_reps.each do |amazon_rep|
          amazon_channel = Channel.find(amazon_rep.channel_id)
          mws = Mws.connect(
              merchant: amazon_channel.connection_1,
              access: amazon_channel.password_1,
              secret: amazon_channel.password_2,
              host: "mws-eu.amazonservices.com"
          )


          result = mws.feeds.get(amazon_rep.document_id)
          if result.status == :complete
            amazon_rep.payload = result.node.to_s
            amazon_rep.payload_datetime = DateTime.now()
            amazon_rep.messages_processed = result.messages_processed
            amazon_rep.messages_successful = result.count_for(:success)
            amazon_rep.messages_with_error = result.count_for(:error)
            amazon_rep.messages_with_warning = result.count_for(:warning)
            amazon_rep.save

            if result.count_for(:error) > 0
              if amazon_rep.channel.admin_user.present?
                Mailer.amazon_feed_error(amazon_rep).deliver!
              end
            end

          end
        end
      end

    rescue => ex
      Rollbar.error(ex)
    end
  end


  def create_amazon_feed(amazon_channel)
    stock_qtys = Item.where(:company_id => amazon_channel.company_id).where("group_stock is not null and amazon_asin IS NOT NULL")

    #default to UK host
    if stock_qtys.count > 0

      feed = Nokogiri::XML::Builder.new(:encoding => 'UTF-8') do |xml|
        xml.AmazonEnvelope('xmlns:xsi' => 'http://www.w3.org/2001/XMLSchema-instance', 'xsi:noNamespaceSchemaLocation' => 'amznenvelope.xsd') {
          xml.Header {
            xml.DocumentVersion '1.01'
            xml.MerchantIdentifier amazon_channel.connection_2
          }
          xml.MessageType 'Inventory'
          stock_qtys.each_with_index do |stock_qty, index|
            xml.Message {
              xml.MessageID (index + 1)
              xml.OperationType "Update"
              xml.Inventory {
                xml.SKU stock_qty.sku
                xml.Quantity stock_qty.group_stock
                xml.FulfillmentLatency 1
              }
            }
          end
        }
      end.to_xml
      File.open("amazon_feed.xml", 'w') { |f| f.write(feed) }
      feed
    end
  end

  def submit_amazon_feed(amazon_channel, feed)

    mws = Mws.connect(
        merchant: amazon_channel.connection_1,
        access: amazon_channel.password_1,
        secret: amazon_channel.password_2,
        host: "mws-eu.amazonservices.com"
    )

    request = mws.feeds.submit feed, {feed_type: :inventory}
    Rails.logger.info("Amazon Feed ID#{request.id}")

    #create amazon report record
    if request.present?
      if request.id.present?
        amazon_rep = AmazonReport.new()
        amazon_rep.company_id = amazon_channel.company_id
        amazon_rep.submission_datetime = DateTime.now()
        amazon_rep.document_id = request.id
        amazon_rep.channel_id = amazon_channel.id
        amazon_rep.save
      end
    end

  end
end