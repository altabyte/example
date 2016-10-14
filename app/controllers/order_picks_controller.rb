class OrderPicksController < ApplicationController
  # GET /order_picks
  # GET /order_picks.json
  add_breadcrumb I18n.t('breadcrumbs.home'), '/'


  def index
    add_breadcrumb I18n.t('breadcrumbs.order_picks'), order_picks_path, {:type => "page_title"}
    #@order_picks = OrderPick.search(params[:search]).page(params[:page]).per(15)
    respond_to do |format|
      format.html # index.html.erb
    end
  end

  # GET /order_picks/1
  # GET /order_picks/1.json
  def show
    @order_pick = OrderPick.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @order_pick }
    end
  end

  # GET /order_picks/new
  # GET /order_picks/new.json
  def new
    @order_pick = OrderPick.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @order_pick }
    end
  end

  # GET /order_picks/1/edit
  def edit
    @order_pick = OrderPick.find(params[:id])
  end

  # POST /order_picks
  # POST /order_picks.json
  def create
    @order_pick = OrderPick.new(params[:order_pick])

    respond_to do |format|
      if @order_pick.save
        format.html { redirect_to @order_pick, notice: 'Order pick was successfully created.' }
        format.json { render json: @order_pick, status: :created, location: @order_pick }
      else
        format.html { render action: "new" }
        format.json { render json: @order_pick.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /order_picks/1
  # PATCH/PUT /order_picks/1.json
  def update
    @order_pick = OrderPick.find(params[:id])

    respond_to do |format|
      if @order_pick.update_attributes(params[:order_pick])
        format.html { redirect_to @order_pick, notice: 'Order pick was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @order_pick.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /order_picks/1
  # DELETE /order_picks/1.json
  def destroy
    @order_pick = OrderPick.find(params[:id])
    @order_pick.destroy

    respond_to do |format|
      format.html { redirect_to order_picks_url }
      format.json { head :no_content }
    end
  end

  def render_pick_notes
    @orders = Order.find(params[:order_ids])
    PickNote.picking_report(@orders, current_user, context_company_id)
    #send_file 'pick_notes.pdf', :type => "application/pdf"
  end

  def update_order_status
    result = Order.pick_orders(params[:order_ids], current_user, session[:current_location_id], context_company_id)
    location = ''
    if result[:report].present?
      location = url_for(result[:report])
    end

    respond_to do |format|
      format.json { render json: {:location => location, :message => result[:message]}, status: :created }
    end
  end

  def get_order
    order_id = params[:order_id].to_i.to_s
    order = Order.find_by_id_and_status_and_company_id(order_id, Order::STATUS_PICKING, context_company_id)
    @country_requires_info = (ShippingDestination.find_by_country_code_and_company_id(order.shipping_address.country, order.channel.company_id) rescue nil)
    render :partial => 'form', :content_type => 'text/html', :locals => {:order => order}, :layout => false, :status => :created
  end

  def update_multiple_picks

    order_pick_data = OrderPick.update_quantities(params[:pick_items], current_user.id, session[:current_location_id], params[:order_id])

    respond_to do |format|
      format.json { render json: {:message => order_pick_data[:message], :success => order_pick_data[:success]}, status: :created }
    end
  end

  autocomplete :hs_code, :description, :display_value => :autocomplete_value, :full => true, :limit => 100, :extra_data => [:code]

  # scope the autocomplete results to ensure only stocked items are returned
  def get_autocomplete_items(parameters)
    HsCode.where("hs_codes.code like :search or hs_codes.description like :search", :search => "%#{params[:term]}%").select('description, code').limit(100)
  end
end
