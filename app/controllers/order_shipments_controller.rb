class OrderShipmentsController < ApplicationController
  # GET /order_shipments
  # GET /order_shipments.json
  add_breadcrumb I18n.t('breadcrumbs.home'), '/'


  def index
    add_breadcrumb I18n.t('breadcrumbs.order_shipments'), order_shipments_path, {:type => "page_title"}
    @shipping_services = ShippingService.where(:active_flag => 1).
        where("company_id is null or company_id = ?", context_company_id).
        where("location_id IS NULL or (location_id = ? and company_id = ?)", @current_location.id, context_company_id).joins(:shipping_method).where("shipping_methods.code != 'FDX'")
    respond_to do |format|
      format.html # index.html.erb
      format.json { render :json => OrderShippingDatatable.new(view_context, session[:current_location_id]) }
    end
  end


  def change_shipping_method

    order_changes = Order.change_shipping_service(params[:order_ids], params[:shipping_service_id])

    respond_to do |format|
      format.json { render json: order_changes, status: :created }
    end
  end

  def ship_orders

    report = OrderShipment.ship_orders(params[:order_ids], session[:current_location_id], current_user, context_company)

    url = ''
    if report.present?
      url = url_for(report)
    end

    respond_to do |format|
      format.json { render json: {:location => url}, status: :created }
    end
  end

  def dispatch_console
    add_breadcrumb I18n.t('breadcrumbs.dispatch_console'), nil, {:type => "page_title"}
  end

  def get_order
    order_id = params[:order_id].to_i.to_s
    order = Order.find_by_id_and_status_and_company_id(order_id, Order::STATUS_AWAITING_TRACKING, context_company_id)

    render :partial => 'dispatch', :content_type => 'text/html', :locals => {:order => order, :read_only => false}, :layout => false, :status => :created
  end

  def update_tracking
    order = Order.find(params[:order][:id])

    if params[:order][:tracking_details].present?
      order.tracking_details = params[:order][:tracking_details]
      order.status = Order::STATUS_DISPATCHED
    end


    respond_to do |format|
      if order.save!
        format.html {
          if request.xhr?
            render :partial => "dispatch", :locals => {:order => order, :read_only => false}, :layout => false, :status => :created
          end }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: order.errors, status: :unprocessable_entity }
      end
    end
    respond_to do |format|
      format.html {

      }
    end
  end

end
