require "net/http"
require "uri"


namespace :excel_clothing do
  desc 'Download Stock Quantities From Magento'
  task :get_stock_quantities => :environment do
    begin
      company = Company.find_by_name('Excel Clothing')
      Rails.logger.info("Downloading stock quantities for Excel Clothing")
      http = Net::HTTP.new("www.excelclothing.com", 80)
      response = http.request(Net::HTTP::Get.new("/scripts/stock_situation.php"))
      if response.body.present?
        doc = REXML::Document.new(response.body.to_s.force_encoding("UTF-8"))
        doc.elements.each('stock_qtys/stock_qty') do |stock_qty|
          item = Item.find_or_initialize_by_sku_and_company_id(stock_qty.elements['sku'].text, company.id)
          item.group_stock = stock_qty.elements['qty'].text.to_i rescue 0
          item.save!
        end
      end
      Delayed::Job.enqueue(AmazonInventoryFeedJob.new(), :queue => 'channel')
    rescue => exc
      Rollbar.error(exc)
    end
  end

  desc 'Process uploaded stock files'
  task :process_stock => :environment do

    begin

      directory = "#{Rails.root}/export/excelclothing/stock_data"
      Dir.foreach(directory) do |item|
        if item.include? '.xml'
          puts "Importing #{item}"
          data = File.read("#{directory}/#{item}")
          company = Company.find_by_name('ExcelClothing.Com')
          ImportInventory.process_import_file(data, company.id)
          puts "Imported #{item} :: deleting"
          File.delete("#{directory}/#{item}")
        end
      end

    rescue => exc
      Rollbar.error(exc)
    end

  end
end
