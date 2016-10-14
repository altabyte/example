class RetryPendingOrdersJob < Struct.new(:company_id)

  def perform
    begin

      pending_orders = PendingOrder.find_all_by_company_id(company_id)

      pending_orders.each do |pending_order|
        ImportOrder.process_import_file(pending_order.order_payload, company_id)
        pending_order.delete
      end

    rescue => ex
      Rollbar.error(ex)
    end

  end

end