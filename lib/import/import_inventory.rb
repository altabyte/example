require 'rexml/document'

module ImportInventory
  def self.process_import_file(data, company_id=nil)

    #export_file_name = self.export_import_data(data)

    doc = REXML::Document.new(data)
    count = 0
    successful_count = 0
    message = ''
    company = Company.find(company_id)
    begin
      custom_logging(company.name, '=========================================')
      custom_logging(company.name, 'Starting Import Inventory')
      doc.elements.each('Inventories/Inventory') do |record|
        processed = self.process_record(record, company_id)
        successful_count += 1 if processed
        count += 1
      end
      custom_logging(company.name, 'Import Inventory Finished')
      custom_logging(company.name, '=========================================')
    rescue => exc
      message = "Failed with error #{exc.to_s}"
      Rails.logger.info("#{exc.to_s}. Import Error")
      Rollbar.error(exc)
    end

    {:success => successful_count, :failed => (count - successful_count), :message => message}
  end

  def self.process_record(record, company_id)
    company = Company.find(company_id)
    type = record.attributes['Type'].to_s
    if record.attributes['Location'].present?
      location = StockLocation.find_by_name_and_company_id(record.attributes['Location'].to_s, company_id)
    elsif record.attributes['LocationReference'].present?
      location = StockLocation.find_by_reference_and_company_id(record.attributes['LocationReference'].to_s, company_id)
    end

    if location.present?
      item = Item.find_by_sku_and_company_id(record.attributes['SKU'].to_s, company_id)
      if item.present?
        iir=ItemInventory.find_or_initialize_by_item_id_and_stock_location_id(item.id, location.id)
        iir.current_stock = 0 if iir.current_stock.blank?
        case type
          when 'TOTAL'
            iir.current_stock = record.elements['Qty'].text.to_d
          when 'POSITIVE'
            iir.current_stock = iir.current_stock + record.elements['Qty'].text.to_d
          when 'NEGATIVE'
            iir.current_stock = iir.current_stock - record.elements['Qty'].text.to_d
        end
        iir.save!
        puts "Imported #{iir.current_stock} for #{item.sku} @ #{location.name}"
        custom_logging(company.name, "Imported #{iir.current_stock} for #{item.sku} @ #{location.name}")
        return true
      else
        puts "Unable to locate item with SKU #{record.attributes['SKU'].to_s}"
        custom_logging(company.name, "Unable to locate item with SKU #{record.attributes['SKU'].to_s}")
        return false
      end
    else
      puts "Unable to locate location with in #{record}"
      custom_logging(company.name, "Unable to locate location with in #{record}")
      return false
    end

  end

  def self.custom_logging(company, message)
    unless Rails.env.test?
      path = "#{Rails.root}/log/customers/#{company}"
      FileUtils.mkdir_p(path)
      log_path = File.open("#{path}/import_inventory.log", 'a')
      log_path.sync = true
      @channel_log ||= CustomLogger.new(log_path, 'daily')
      @channel_log.info "#{message}"
    end
  end
end