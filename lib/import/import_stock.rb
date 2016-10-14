require 'rexml/document'

module ImportStock
  def self.process_import_file(data, company_id=nil)

    #export_file_name = self.export_import_data(data)

    doc = REXML::Document.new(data)
    count = 0
    successful_count = 0
    message = ''

    begin
      doc.elements.each('Items/ItemStock') do |record|
        processed = self.process_record(record, company_id)
        successful_count += 1 if processed
        count += 1
      end
    rescue => exc
      message = "Failed with error #{exc.to_s}"
      Rails.logger.info("#{exc.to_s}. Import Error")
      Rollbar.error(exc)
    end

    {:success => successful_count, :failed => (count - successful_count), :message => message}
  end

  def self.process_record(record, company_id)

    type = record.attributes['Type'].to_s

    item = Item.find_by_sku_and_company_id(record.attributes['SKU'].to_s, company_id)

    if item.present?
      item.group_stock = 0 if item.group_stock.blank?
      case type
        when 'TOTAL'
          item.group_stock = record.elements['Qty'].text.to_d
        when 'POSITIVE'
          item.group_stock = item.group_stock + record.elements['Qty'].text.to_d
        when 'NEGATIVE'
          item.group_stock = item.group_stock - record.elements['Qty'].text.to_d
      end
      item.save!
    else
      return false
    end
  end
end