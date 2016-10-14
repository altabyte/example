class OrdersController < ApplicationController
  # GET /orders
  # GET /orders.json

  add_breadcrumb I18n.t('breadcrumbs.home'), '/'


  def index
    add_breadcrumb I18n.t('breadcrumbs.orders'), orders_path, {:type => "page_title"}
    @company_id = @current_user.company_id.present? ? @current_user.company_id : context_company_id

    respond_to do |format|
      format.html # index.html.erb
      format.json { render :json => OrdersDatatable.new(view_context, params[:show], context_company_id, current_user) }
    end
  end

  def pending_orders
    add_breadcrumb I18n.t('breadcrumbs.pending_orders'), orders_pending_orders_path, {:type => "page_title"}

    respond_to do |format|
      format.html # index.html.erb
      format.json { render :json => PendingOrdersDatatable.new(view_context, @current_user.company_id) }
    end
  end

  def retry_pending_orders
    job = Delayed::Job.enqueue RetryPendingOrdersJob.new(@current_user.company_id), :queue => "channel"
    if job.present?
      result = I18n.t('orders.pending_orders.orders_queued_for_retry')
    else
      result = I18n.t('orders.pending_orders.failed_to_queue_orders_for_retry')
    end

    respond_to do |format|
      format.json { render :json => {:result => result} }
    end

  end

  def get_pending_payload
    @order_payload = PendingOrder.find(params[:id]).order_payload

    payload = Nokogiri::XML(@order_payload) { |config| config.options = Nokogiri::XML::ParseOptions::STRICT }
    payload.to_xml(:indent => 2)

    respond_to do |format|
      format.json { render :json => {:order_payload => payload.to_xml(:indent => 2)} }
    end

  end


  # GET /orders/1
  # GET /orders/1.json
  def show
    @order = Order.find(params[:id])
    respond_to do |format|
      format.html {
        if request.xhr?
          render :partial => "orders/order_information", :locals => {:order => @order, :read_only => false}, :layout => false, :status => :created
        end
      }
    end
  end

  def reprint_rm_label
    @order = Order.find(params[:id])

    job = DmoReprintJob.new(@order)
    job.perform

    respond_to do |format|
      format.html {
        if request.xhr?
          render :partial => "orders/order_information_tabs", :locals => {:order => @order, :read_only => false}, :layout => false, :status => :created
        end
      }
    end
  end


  def order_details
    @order_details = OrderDetail.find_all_by_order_id(params[:id])

    respond_to do |format|
      format.json { render json: @order_details.as_json(:include => {:item_inventories => {:include => :stock_location}}, :methods => [:country_string, :quantity_picked, :item]) }
    end

  end

  def update_order_status
    @order = Order.find(params[:order_id])
    @order.new_status(params[:new_status])

    respond_to do |format|
      format.json { render json: @order, status: :created }
    end

  end

  def shipment_check
    add_breadcrumb I18n.t('breadcrumbs.shipment_check'), nil, {:type => "page_title"}
    respond_to do |format|
      format.html # index.html.erb
    end
  end

  def shipment_check_datatable
    respond_to do |format|
      format.json { render :json => ShipmentCheckDatatable.new(view_context, @current_location.id) }
    end
  end

  def do_shipment_check

    order_id = params[:order_id]
    tracking_number = params[:tracking_number]

    result = OrderShipment.check_shipment(order_id, tracking_number, context_company_id)


    respond_to do |format|
      format.json { render json: {:result => result[:result], :message => result[:message]} }
    end
  end

  def aftership_tracking
    orders = Order.find(params[:id])
    @tracking_info = orders.get_aftership_status
    respond_to do |format|
      format.html {
        if request.xhr?
          render :partial => "orders/aftership_tracking", :layout => false, :status => :created
        end
      }
    end


  end

end
