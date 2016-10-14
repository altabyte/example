class Order < ActiveRecord::Base
  include CompanyOnly

  belongs_to :channel
  belongs_to :customer
  has_many :order_details, :foreign_key => "order_id"
  has_many :order_picks
  has_many :order_shipments
  has_one :order_fraud_score
  belongs_to :company
  has_many :order_status_histories
  belongs_to :channel_shipping_service
  has_one :shipping_service, :through => :channel_shipping_service
  has_one :shipping_method, :through => :shipping_service

  belongs_to :billing_address, :class_name => 'CustomerAddress'
  belongs_to :shipping_address, :class_name => 'CustomerAddress'
  has_many :items, :through => :order_details
  has_many :order_errors

  validates_uniqueness_of :channel_order_id, :scope => :channel_id

  STATUS_NEW='NEW'
  STATUS_PENDING='PENDING'
  STATUS_PICKING='PICKING'
  STATUS_PART_PICKED='PART_PICKED'
  STATUS_PICKED='PICKED'
  STATUS_PART_DISPATCHED='PART_DISPATCHED'
  STATUS_DISPATCHED='DISPATCHED'
  STATUS_COMPLETE='COMPLETE'
  STATUS_CANCELLED='CANCELLED'
  STATUS_REFUNDED='REFUNDED'
  STATUS_AWAITING_TRACKING='AWAITING_TRACKING'
  STATUS_AWAITING_INTEGRATION_INFO='AWAITING_INTEGRATION_INFO'
  STATUS_WEIGHED='WEIGHED'
  STATUS_DELIVERED='DELIVERED'
  STATUS_ON_HOLD='ON_HOLD'
  STATUS_COMPLETE_WITH_ERROR='COMPLETE_WITH_ERROR'
  STATUS_SHIPMENT_PENDING='SHIPMENT_PENDING'
  STATUS_SHIPMENT_IN_TRANSIT='SHIPMENT_IN_TRANSIT'
  STATUS_SHIPMENT_DELIVERED='SHIPMENT_DELIVERED'
  STATUS_SHIPMENT_ATTEMPT_FAIL='SHIPMENT_ATTEMPT_FAIL'
  STATUS_SHIPMENT_OUT_FOR_DELIVERY='SHIPMENT_OUT_FOR_DELIVERY'
  STATUS_SHIPMENT_EXCEPTION='SHIPMENT_EXCEPTION'
  STATUS_SHIPMENT_EXPIRED='SHIPMENT_EXPIRED'
  STATUS_SHIPMENT_INFO_RECEIVED='SHIPMENT_INFO_RECEIVED'
  STATUS_IN_PROGRESS='IN_PROGRESS'

  def update_status(new_status)
    OrderStatusHistory.new_status_update(self.id, self.status, new_status)
    self.status = new_status
    self.save!
  end

  def self.get_statuses
    status = []
    self.constants.each do |const|
      if const.to_s.start_with? 'STATUS_'
        status << const
      end
    end
    status
  end

  def status_name
    I18n.t("statuses.#{self.status.downcase}") rescue ''
  end

  def shipping_name
    if self.shipping_address.name.present?
      add = shipping_address.name
    else
      add = customer.full_name
    end
    add.to_s.gsub(',', ' ') rescue ''
  end


  def actual_shipping_service
    if self.override_shipping_service_id.blank?
      proper_shipping_service = shipping_service
    else
      proper_shipping_service = ShippingService.find(self.override_shipping_service_id) rescue nil
    end
    proper_shipping_service
  end

  def self.cleardown_data(company_id, date_timestamp)
    orders = Order.where(:company_id => company_id).where("order_date <= '#{date_timestamp}'")
    order_count = orders.count
    order_ids = orders.collect(&:id)
    OrderShipment.delete_all(:order_id => order_ids)
    OrderPick.delete_all(:order_id => order_ids)
    OrderStatusHistory.delete_all(:order_id => order_ids)
    orders.delete_all

    reports = Report.where("created_at <= '#{date_timestamp}'").where(:company_id => company_id)
    report_count = reports.count
    reports.delete_all

    customers = Customer.where("created_at <= '#{date_timestamp}'").where('id NOT IN (SELECT customer_id FROM orders WHERE customer_id IS NOT NULL GROUP BY customer_id)').where(:company_id => company_id)
    customers_count = customers.count
    customers.delete_all

    {
        :orders => order_count,
        :reports => report_count,
        :customers => customers_count
    }
  end

  def self.change_status(company_id, date_timestamp, old_status, new_status)
    orders = Order.where(:company_id => company_id).where("order_date <= '#{date_timestamp}'").where(:status => old_status)
    if orders.present?
      new_status = "Order::STATUS_#{new_status}".constantize
      orders.all.each do |order|
        order.update_status(new_status)
      end
    end

    {
        :orders => orders.all.count
    }
  end

  def new_status(new_status)

    if self.status == STATUS_IN_PROGRESS
      OrderPick.where(:order_id => self.id).each do |op|
        iv = ItemInventory.where(:stock_location_id => op.location_id).where(:item_id => op.item_id).first

        if iv.present?
          iv.current_stock = iv.current_stock + op.quantity_picked
          iv.save
        end
      end
      OrderPick.delete_all(:order_id => self.id)
      OrderShipment.delete_all(:order_id => self.id)
    end

    self.update_status(new_status)
  end

  def ship_order
    if self.actual_shipping_service.tracked == 1 and self.tracking_details.blank?
      self.update_status(STATUS_AWAITING_TRACKING)
    else
      self.update_status(STATUS_DISPATCHED)
    end
  end

  def get_aftership_token
    require 'aftership'
    AfterShip.api_key = self.company.aftership_api_key
    response = AfterShip::V4::Tracking.create(self.tracking_details, {:order_id => self.channel_order_id, :slug => self.actual_shipping_service.shipping_method.aftership_code})
    if response['data']['tracking']['unique_token']
      self.aftership_token = response['data']['tracking']['unique_token']
      self.save!
    elsif self.aftership_token == response['data']['tracking']['slug']
      AfterShip::V4::Tracking.delete(response['data']['tracking']['slug'], response['data']['tracking']['tracking_number'])
      self.get_aftership_token
    end
  end

  def get_aftership_status
    begin
      require 'aftership'
      AfterShip.api_key = self.company.aftership_api_key
      response = AfterShip::V4::Tracking.get(self.actual_shipping_service.shipping_method.aftership_code, self.tracking_details)
      response['data']['tracking']
    rescue
      'Unable to get tracking status from AfterShip'
    end
  end

  def get_aftership_tracking
    begin
      require 'aftership'
      AfterShip.api_key = self.company.aftership_api_key
      response = AfterShip::V4::Tracking.get(self.actual_shipping_service.shipping_method.aftership_code, self.tracking_details)
      response['data']['tracking']['checkpoints']
    rescue
      'Unable to get tracking status from AfterShip'
    end
  end

  def self.update_aftership_statuses
    require 'aftership'
    begin
      Company.where('aftership_api_key IS NOT NULL').all.each do |company|

        trackable_orders = Order.where('aftership_token IS NOT NULL').where(:company_id => company.id).collect(&:id)

        limit = 200
        AfterShip.api_key = company.aftership_api_key
        response = AfterShip::V4::Tracking.get_all(:limit => limit)
        count = response['data']['count'].to_i
        page = response['data']['page'].to_i

        puts "Received #{count} tacking responses"

        processed_tracks = process_aftership_tracks(response, company.id)

        if count > limit
          begin
            page += 1
            response = AfterShip::V4::Tracking.get_all(:limit => limit, :page => page)
            puts "Processing page #{page} of aftership"
            processed_tracks= processed_tracks + process_aftership_tracks(response, company.id)
          end while response['data']['trackings'].count > 0
        end

        if trackable_orders.count > 0 and processed_tracks.count > 0
          untracked_orders = trackable_orders - processed_tracks

          if untracked_orders.count > 0
            email = ''
            email1 = ''
            untracked_orders.each do |order|
              orders= Order.find(order)
              response = AfterShip::V4::Tracking.get(orders.actual_shipping_service.shipping_method.aftership_code, orders.tracking_details)
              if response['data'].blank?
                email1 += "<br>#{orders.id},#{orders.tracking_details},#{orders.actual_shipping_service.shipping_method.aftership_code},#{orders.aftership_token}"
                orders.aftership_token = nil
                orders.save!
                orders.get_aftership_token
                response = AfterShip::V4::Tracking.get(orders.actual_shipping_service.shipping_method.aftership_code, orders.tracking_details)
              end
              if response['data'].present?
                Order.process_aftership_data(response['data']['tracking'], company.id)
              end
              email += "<br>#{orders.id},#{orders.tracking_details},#{orders.actual_shipping_service.shipping_method.aftership_code},#{orders.aftership_token}"
            end

            body = 'The Aftership tracking API failed to return the following tracking information:'
            body += email unless email.blank?
            body += '<br><br>'
            body += 'The follow tracking tokens have been replaced because they did not return any data:' unless email1.blank?
            body += email1

            Mailer.generic_message('Aftership Tracking API', body, 'stuart.drennan@gmail.com').deliver!
          end
        end
      end
    rescue => exc
      puts exc.to_s
    end
  end

  def self.process_aftership_data(track, company_id)
    if track['tag'].present?
      order = Order.find_by_aftership_token_and_company_id(track['unique_token'], company_id)
      order = Order.find_by_channel_order_id_and_tracking_details_and_company_id(track['order_id'], track['tracking_number'], company_id) if order.blank?
      shipment_status = "SHIPMENT_#{track['tag'].to_s.underscore.to_s.upcase}"
      if order.present?
        if order.status != shipment_status
          order.update_status(shipment_status)
        end
        if order.aftership_token.blank?
          order.aftership_token = track['unique_token']
        end
        if shipment_status == STATUS_SHIPMENT_DELIVERED
          order.delivered_date = (Time.parse(track['checkpoints'][-1]['checkpoint_time']) rescue '')
          order.aftership_signed_by = (track['signed_by'] rescue '')
        end
        order.aftership_status = (track['tag'] rescue '')
        order.save!
        return {:success => true, :message => order.id}
      else
        puts 'Unable to match order to aftership response'
        puts track
        return {:success => false, :message => 'unable to match order to tracking details'}
      end
    else
      puts 'No tag present'
      puts track
      return {:success => false, :message => 'tag missing'}
    end
  end

  def self.process_aftership_tracks(response, company_id)
    orders = []
    begin
      response['data']['trackings'].each do |track|
        result = process_aftership_data(track, company_id)
        orders << result[:message] if result[:success]
      end
      orders
    rescue => exc
      puts exc.to_s
    end
  end

  def self.pick_orders(order_ids, current_user, location_id, context_company_id)
    orders = Order.find(order_ids)
    message = ''
    report = {}

    orders.each do |order|
      if order.status != Order::STATUS_NEW
        message += "Order ID #{order.id} is not pickable. <br>"
      end
    end

    message +='</br>Please reselect your orders to pick' if message.present?

    Order.transaction do
      if message.blank?
        begin

          orders.each do |order|
            order.update_status(Order::STATUS_PICKING)
          end

          report = PickNote.picking_report(orders, current_user, context_company_id)
        rescue => exc
          message = "Error Generating Pick Notes. Please check order details."
          Rails.logger.error(exc)
          Rollbar.error(exc)
          raise ActiveRecord::Rollback
        end
      end
    end

    {:report => report, :message => message}

  end

  def clone_for_balance
    new_order = self.dup
    new_order.status = STATUS_NEW
    new_order.part_order_sequence = self.part_order_sequence + 1
    if self.original_order_id.present?
      new_order.channel_order_id = "#{Order.find_by_id(self.original_order_id).channel_order_id}-#{new_order.part_order_sequence}"
      new_order.original_order_id = self.original_order_id
    else
      new_order.channel_order_id = "#{self.channel_order_id}-#{new_order.part_order_sequence}"
      new_order.original_order_id = self.id
    end


    new_order.save!

    self.order_details.each do |order_detail|
      if order_detail.remaining_qty > 0
        new_order_detail = order_detail.dup
        new_order_detail.order_id = new_order.id
        new_order_detail.quantity_ordered = order_detail.remaining_qty
        new_order_detail.save!
      end
    end
  end

  def weigh_order(params, new_shipping_srv_id)

    OrderShipment.transaction do
      begin
        shipping_weight = params[:shipping_weight]
        comp_pack_type_id = params[:company_packaging_type_id]
        package_height = params[:package_height]
        package_width = params[:package_width]
        package_length = params[:package_length]
        max_order_weight = SystemSetting.check_setting('max_order_weight', 20, self.company_id).to_i
        if shipping_weight.present? and shipping_weight.to_d < max_order_weight
          if new_shipping_srv_id.present?
            self.override_shipping_service_id = new_shipping_srv_id
            self.save
          end
          self.shipping_weight = shipping_weight
          self.company_packaging_type_id = comp_pack_type_id
          self.package_height = package_height
          self.package_width = package_width
          self.package_length = package_length
          self.status = STATUS_WEIGHED
          self.save!
        elsif shipping_weight.blank?
          errors.add(:shipping_weight, "cannot be blank")
        else
          errors.add(:shipping_weight, "cannot be more than #{max_order_weight}kg")
        end

      rescue => exc
        errors.add(:shipping_weight, exc.to_s)
        raise ActiveRecord::Rollback
      end
    end
  end

  def self.change_shipping_service(order_ids, new_service_id)
    Order.transaction do
      begin
        Order.update_all("override_shipping_service_id = #{new_service_id}", "id IN (#{order_ids.join(',')})")
      rescue => exc
        return {:success => false, :message => "Error updating shipping services: #{exc.to_s}"}
      end
      {:success => true, :message => nil}
    end

  end


  def confirm_tracking
    if (self.status == STATUS_AWAITING_TRACKING or self.status == STATUS_AWAITING_INTEGRATION_INFO) and self.tracking_details.present?
      self.update_status(STATUS_DISPATCHED)
    end
  end

  def complete?
    complete = true
    self.order_details.each do |detail|
      if detail.remaining_qty > 0
        complete = false
      end
      break unless complete
    end
    complete
  end

  def linked_orders
    if self.original_order_id.present?
      orders = Order.where("original_order_id = #{self.original_order_id} OR id = #{self.original_order_id}").where("id != #{self.id}")
    else
      orders = Order.where("original_order_id = #{self.id}")
    end
    orders.order('created_at ASC')
  end
end
