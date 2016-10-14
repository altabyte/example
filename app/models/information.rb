class Information

  def self.information_data(company_id, location_id)
    if company_id.present? and location_id.present?
      shipments = Order.where(:status => Order::STATUS_AWAITING_TRACKING).where(:company_id => company_id).joins(:order_shipments).where("order_shipments.stock_location_id = ?", location_id).all
      missing_tracking_info = shipments.count > 0
      new_orders = Order.find_all_by_status_and_company_id(Order::STATUS_NEW, company_id).count > 0
      fedex_shipments = FedexShipment.for_company(company_id).not_printed.count > 0
      company_errors = CompanyLog.find_all_by_log_level_and_company_id_and_read('ERROR', company_id, 0).count > 0
      pending_orders = PendingOrder.find_all_by_company_id(company_id).count > 0
      show_panel = (missing_tracking_info or new_orders or company_errors or fedex_shipments)
      data = {
          :show_panel => show_panel,
          :missing_tracking_info => missing_tracking_info,
          :new_orders => new_orders,
          :company_errors => company_errors,
          :fedex_shipments => fedex_shipments,
          :pending_orders => pending_orders
      }
    else
      data = {
          :show_panel => false
      }
    end
    data
  end

end