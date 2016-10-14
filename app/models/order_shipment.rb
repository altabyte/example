require 'net/ftp'

class OrderShipment < ActiveRecord::Base

  belongs_to :item
  belongs_to :stock_location, :foreign_key => 'location_id'
  belongs_to :order
  belongs_to :shipping_service
  has_one :shipping_method, :through => :shipping_service
  belongs_to :company
  has_many :order_picks
  belongs_to :user

  STATUS_CREATED='CREATED'
  STATUS_PICKED='PICKED'
  STATUS_WEIGHED='WEIGHED'
  STATUS_COMPLETE='COMPLETE'
  STATUS_SHIPPED='SHIPPED'
  STATUS_REFUNDED='REFUNDED'
  STATUS_AWAITING_TRACKING='AWAITING_TRACKING'
  STATUS_AWAITING_INTEGRATION_INFO='AWAITING_INTEGRATION_INFO'

  def self.find_by_shipment_id_or_barcode(reference, status, company_id)
    shipment = OrderShipment.where(:id => reference)
    shipment = OrderShipment.where(:barcode => reference) if shipment.blank?
    shipment = shipment.where(:company_id => company_id)
    if status
      shipment = shipment.where(:status => status)
    end
    shipment.first
  end


  def self.ship_orders(order_ids, current_location, current_user, company)

    orders = Order.find(order_ids)
    dpd_orders = []
    fdx_orders = []
    dmo_orders = []

    orders.each do |order|
      order.shipment_error = nil
      order.save!
      if order.actual_shipping_service.shipping_method.code == "RM"
        order.update_status(Order::STATUS_AWAITING_INTEGRATION_INFO)
        dmo_orders << order
      elsif order.actual_shipping_service.shipping_method.code=="DPD-IE"
        order.update_status(Order::STATUS_AWAITING_INTEGRATION_INFO)
        dpd_orders << order
      elsif order.actual_shipping_service.shipping_method.code=="FDX"
        order.update_status(Order::STATUS_AWAITING_INTEGRATION_INFO)
        fdx_orders << order
      else
        order.ship_order
      end
      ExportShipments.export_shipment(order, company, current_user, current_location) if SystemSetting.check_setting('export_orders', true, company.id)
      order.save!
    end


    if dpd_orders.count > 0
      begin
        job = DpdIeShipOrderJob.new(dpd_orders, current_location, company)
        job.perform
      rescue => exc
        location = StockLocation.find(current_location)
        CompanyLog.create(
            :company_id => location.company_id,
            :log_level => 'ERROR',
            :date_timestamp => DateTime.now(),
            :message => ("DPD Export Failed @ #{location.name}: Error Returned: #{exc}")
        )
        dpd_orders.each do |order|
          order.update_status(Order::STATUS_WEIGHED)
        end
      end
    end


    if fdx_orders.count > 0
      fdx_orders.each do |order|
        FedexSetting.ship_order(order, current_location)
      end
    end

    if dmo_orders.count > 0
      Delayed::Job.enqueue DmoOrderShipmentJob.new(dmo_orders, current_location, company), :queue => "dmo"
    end


    if SystemSetting.check_setting('display_shipping_note', true, company.id)
      return ShipmentNote.shipment_report(orders, current_user, company.id)
    else
      return nil
    end
  end

  def self.check_shipment(order_id, tracking_number, company_id)
    result = true
    message = ''

    this_order = Order.find_by_id_and_company_id(order_id, company_id)

    if this_order.blank?
      result = false
      message = 'Unable to find order.'
    else
      if this_order.shipment_check_failed == 999
        result = false
        message = 'Order already checked.'
      end
    end

    if result
      tracking_record = Order.find_by_tracking_details_and_company_id(tracking_number, company_id)

      if this_order.present? and tracking_record.blank?
        if this_order.shipping_service.shipping_method.code == 'DPD-IE'
          tracking_number = tracking_number.to_s.slice(12..20)
          tracking_record = Order.find_by_tracking_details_and_company_id(tracking_number, company_id)
        end
      end

      if tracking_record.blank?
        result = false
        if message.present?
          message += ' '
        end
        message += 'Unable to find tracking number.'
        if this_order.present?
          this_order.shipment_check_failed.blank? ? this_order.shipment_check_failed = 1 : this_order.shipment_check_failed += 1
          this_order.shipment_checked_by = User.current_user.id
          this_order.save

          if this_order.company.user_id.present?
            body = "Shipment checked failed because of an invalid tracking number for Shipment ID: #{this_order.id} on #{Time.now} by user: #{User.current_user.name}.
                  The check has failed <bold>#{this_order.shipment_check_failed}</bold> time(s)<br>The entered tracking number was #{tracking_number}"
            Mailer.generic_message('Shipment Check Failed', body, this_order.company.user.email).deliver!
          end
        end
      end

      if tracking_record.present? and this_order.present?
        if tracking_record.id != this_order.id
          result = false
          message = "Tracking number and order do not match!<br><br>
                  <table><tr><th>Order</th><th>Tracking Number</th></tr><tr><td>#{this_order.shipping_address.to_html}</td><td>#{tracking_record.shipping_address.to_html}</td></tr></table>"
          this_order.shipment_check_failed.blank? ? this_order.shipment_check_failed = 1 : this_order.shipment_check_failed += 1
          this_order.shipment_checked_by = User.current_user.id
          this_order.save

          if this_order.company.user_id.present?
            body = "Shipment checked failed because of a tracking number mismatch for Shipment ID: #{this_order.id} on #{Time.now} by user: #{User.current_user.name}.
                  The check has failed <bold>#{this_order.shipment_check_failed}</bold> time(s)<br>The entered tracking number was #{tracking_number}"
            Mailer.generic_message('Shipment Check Failed', body, this_order.company.user.email).deliver!
          end
        else
          this_order.shipment_checked_by = User.current_user.id
          this_order.shipment_check_failed = 999
          this_order.save
        end
      end
    end

    return {:result => result, :message => message}

  end

end