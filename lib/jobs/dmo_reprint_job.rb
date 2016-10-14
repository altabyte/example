class DmoReprintJob < Struct.new(:order, :current_location)

  def perform

    begin
      require 'fileutils'
      import_data_path = Rails.root.join('export', order.channel.company.client_share, 'order_shipping', 'dmo', order.order_shipments.first.stock_location.name, 'import')
      export_data_path = Rails.root.join('export', order.channel.company.client_share, 'order_shipping', 'dmo', order.order_shipments.first.stock_location.name, 'export')

      FileUtils.mkpath(import_data_path)
      FileUtils.mkpath(export_data_path)

      data_file = export_data_path + "Data.txt"
      lock_file = export_data_path + "Lock.txt"
      result_file = import_data_path + "Result.txt"

      if File.exist?(data_file)
        File.delete(data_file)
      end

      if File.exist?(lock_file)
        File.delete(lock_file)
      end

      if File.exist?(result_file)
        File.delete(result_file)
      end

      text_file = "REPRINT\n"
      text_file << order.channel_order_id.to_s

      if text_file.present?
        my_file = File.new(lock_file, "w")
        my_file.write text_file
        my_file.close
      end

      if text_file.present?
        my_file = File.new(data_file, "w")
        my_file.write text_file
        my_file.close
      end

    rescue => ex
      Rollbar.error(ex)
      Rails.logger.error(ex)
    end
  end

  def max_attempts
    return 1
  end

  def error(job, exception)
  end

end