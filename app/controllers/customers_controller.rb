class CustomersController < ApplicationController

  add_breadcrumb I18n.t('breadcrumbs.home'), "/"

  # GET /customers
  # GET /customers.json
  def index
    add_breadcrumb I18n.t('breadcrumbs.customers'), customers_path, {:type => "page_title"}
    respond_to do |format|
      format.html # index.html.erb
      format.json { render :json => CustomersDatatable.new(view_context, context_company_id) }
    end
  end

  # GET /customers/1
  # GET /customers/1.json
  def show
    @customer = Customer.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @customer }
    end
  end

  # GET /customers/new
  # GET /customers/new.json
  def new
    @customer = Customer.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @customer }
    end
  end

  # GET /customers/1/edit
  def edit
    @customer = Customer.find(params[:id])
    respond_to do |format|
      format.html {
        if request.xhr?
          render :partial => "customers/form", :locals => {:customer => @customer, :show => false, :read_only => false}, :layout => false, :status => :created
        else
          redirect_to(@customer, :notice => "")
        end
      }
    end
  end

  # POST /customers
  # POST /customers.json
  def create
    @customer = Customer.new(params[:customer])

    respond_to do |format|
      if @customer.save
        format.html { redirect_to @customer, notice: 'Customer was successfully created.' }
        format.json { render json: @customer, status: :created, location: @customer }
      else
        format.html { render action: "new" }
        format.json { render json: @customer.errors, status: :unprocessable_entity }
      end
    end
  end

  def list_orders
    @customer = Customer.find(params[:id])

    respond_to do |format|
      format.json { render :json => CustomerOrderHisDatatable.new(view_context, params[:id]) }
    end
  end

  def update_basic_details
    @customer = Customer.find(params[:id])
    respond_to do |format|
      if @customer.update_attributes(params[:customer])
        format.html {
          if request.xhr?
            render :partial => "customers/tabs/basic_details", :locals => {:customer => @customer, :read_only => false}, :layout => false, :status => :created
          end
        }
        format.json { render :json => {success: "Success"} }
        format.js {}
      else
        format.html {
          if request.xhr?
            render :partial => "customers/tabs/basic_details", :locals => {:customer => @customer, :read_only => false}, :layout => false, :status => :unprocessable_entity
          end
        }
      end
    end
  end

  def list_customer_addresses
    @customer = Customer.find(params[:id])

    respond_to do |format|
      format.json { render :json => CustomerAddressesDatatable.new(view_context, params[:id]) }
    end
  end

  def update_customer_address
    @customer_address = CustomerAddress.find(params[:customer_address][:id])
    respond_to do |format|
      if @customer_address.update_attributes(params[:customer_address])
        format.html {
          if request.xhr?
            render :partial => "customers/forms/customer_address", :locals => {:customer_address => @customer_address, :read_only => false}, :layout => false, :status => :created
          end
        }
      else
        format.html {
          if request.xhr?
            render :partial => "customers/forms/customer_address", :locals => {:customer_address => @customer_address, :read_only => false}, :layout => false, :status => :unprocessable_entity
          end
        }
      end
    end
  end

  def edit_customer_address
    @customer_address = CustomerAddress.find(params[:id])
    respond_to do |format|
      format.html {
        if request.xhr?
          render :partial => "customers/forms/customer_address", :locals => {:customer_address => @customer_address, :read_only => false}, :layout => false, :status => :created
        end
      }
    end
  end


  # PATCH/PUT /customers/1
  # PATCH/PUT /customers/1.json
  def update
    @customer = Customer.find(params[:id])

    respond_to do |format|
      if @customer.update_attributes(params[:customer])
        format.html { redirect_to @customer, notice: 'Customer was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @customer.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /customers/1
  # DELETE /customers/1.json
  def destroy
    @customer = Customer.find(params[:id])
    @customer.destroy

    respond_to do |format|
      format.html { redirect_to customers_url }
      format.json { head :no_content }
    end
  end

  def postcode_search
    require 'postcode_anywhere'
    data = []
    if params[:postcode].present?
      pcaw_key = SystemSetting.check_setting('postcode_anywhere_key', nil, context_company_id)
      iso_country = params[:country].present? ? params[:country] : 'GB'
      data = PostCodeAnywhere.CapturePlus_Interactive_Find_v2_00(pcaw_key, params[:postcode], nil, nil, iso_country, nil)
    end
    respond_to do |format|
      format.json { render :json => {:data => data} }
    end
  end

  def postcode_get_by_id
    require 'postcode_anywhere'
    if params[:address_id].present?
      pcaw_key = SystemSetting.check_setting('postcode_anywhere_key', nil, context_company_id)
      data = PostCodeAnywhere.CapturePlus_Interactive_Retrieve_v2_00(pcaw_key, params[:address_id])
    end
    respond_to do |format|
      format.json { render :json => {:data => data} }
    end
  end

  def edit_shipping_address
    orders = Order.find(params[:id])

    @customer_address = orders.shipping_address

    respond_to do |format|
      format.html {
        if request.xhr?
          render :partial => "customers/forms/customer_address", :locals => {:customer_address => @customer_address, :read_only => false}, :layout => false, :status => :created
        end
      }
    end
  end
end
