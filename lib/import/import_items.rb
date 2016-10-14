require 'rexml/document'

module ImportItems
  def self.process_import_file(data, company_id)

    doc = REXML::Document.new(data)
    item_count = 0
    success_item_count = 0
    message = ''

    begin
      doc.elements.each('Items/Item') do |item|
        result = self.process_item(item, company_id)
        success_item_count += 1 if result
        item_count += 1
      end
    rescue => exc
      message = "Item Import Failed with error #{exc.to_s}"
      Rollbar.error(exc)
    end

    {:success => success_item_count, :failed => (item_count - success_item_count), :message => message}
  end

  def self.process_item(item, company_id)
    if item.elements['SKU'].text.present? and item.elements['ItemName'].text.present?
      begin
        import_item = Item.find_or_initialize_by_sku_and_company_id(item.elements['SKU'].text, company_id)
        import_item.name = item.elements['ItemName'].text
        import_item.description = item.elements['Description'].text rescue nil
        import_item.colour = item.elements['Colour'].text rescue nil
        import_item.size = item.elements['Size'].text rescue nil
        import_item.harmonization_code = item.elements['HarmonizationCode'].text rescue nil
        import_item.country_code = item.elements['CountyOfOrigin'].text rescue nil
        import_item.item_weight = item.elements['ItemWeight'].text.to_d rescue nil
        import_item.save
        return true
      rescue
        return false
      end
    else
      return false
    end
  end
end