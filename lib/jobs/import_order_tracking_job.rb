class ImportOrderTrackingJob

  def perform

    begin
      require 'csv'
      Rails.logger.info("Import DPD Tracking Details")

      comps = Company.where("client_share IS NOT NULL")

      comps.all.each do |company|
        company_file_path = Rails.root.join('export', company.client_share, 'order_shipping', 'dpd')
        if File.directory?(company_file_path)
          stock_locations = StockLocation.find_all_by_company_id(company.id)
          stock_locations.each do |stock_location|

            file_path = Rails.root.join(company_file_path, stock_location.name, 'export')
            if File.directory?(file_path)
              Dir.foreach(file_path) do |item|
                next if item == '.' or item == '..'
                CSV.foreach(Rails.root.join(file_path, item), :headers => false) do |row|
                  order_header = Order.find_by_channel_order_id(row[0])
                  if order_header.present?
                    order_header.tracking_details = row[2]
                    order_header.save
                    order_header.confirm_tracking
                  end
                end
                File.delete(Rails.root.join(file_path, item))
              end
            end
          end
        end
      end

    rescue => ex
      Rollbar.error(ex)
    end

  end

end