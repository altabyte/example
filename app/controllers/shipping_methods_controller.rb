class ShippingMethodsController < ApplicationController
  add_breadcrumb I18n.t('breadcrumbs.home'), "/"

  # GET /customers
  # GET /customers.json
  def index
    add_breadcrumb I18n.t('breadcrumbs.shipping_methods'), shipping_methods_path, {:type => "page_title"}
    respond_to do |format|
      format.html # index.html.erb
      format.json { render :json => ShippingMethodsDatatable.new(view_context) }
    end
  end

  # GET /shipping_methods/1/edit
  def edit
    @shipping_method = ShippingMethod.find(params[:id])
    respond_to do |format|
      format.html {
        if request.xhr?
          render :partial => "setup/forms/shipping_methods/shipping_methods_edit", :locals => {:shipping_method => @shipping_method, :show => false, :read_only => false}, :layout => false, :status => :created
        else
          redirect_to(@shipping_method, :notice => "")
        end
      }
    end
  end

  # POST /shipping_methods
  # POST /shipping_methods.json
  def create
    @shipping_method = ShippingMethod.new(params[:shipping_method])

    respond_to do |format|
      if @shipping_method.save
        format.html { redirect_to @shipping_method, notice: 'Shipping method was successfully created.' }
        format.json { render json: @shipping_method, status: :created, location: @shipping_method }
      else
        format.html { render action: "new" }
        format.json { render json: @shipping_method.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /shipping_methods/1
  # PATCH/PUT /shipping_methods/1.json
  def update
    @shipping_method = ShippingMethod.find(params[:id])
    @packaging_types = []

    respond_to do |format|
      if @shipping_method.update_attributes(params[:shipping_method])
        format.html { redirect_to @shipping_method, notice: 'Shipping method was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @shipping_method.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /shipping_methods/1
  # DELETE /shipping_methods/1.json
  def destroy
    @shipping_method = ShippingMethod.find(params[:id])
    @shipping_method.destroy

    respond_to do |format|
      format.html { redirect_to shipping_methods_url }
      format.json { head :no_content }
    end
  end

  def list_shipping_services
    respond_to do |format|
      format.json { render :json => ShippingServicesDatatable.new(view_context, params[:id], current_user) }
    end
  end

  def delete_shipping_service
    @shipping_service = ShippingService.find(params[:id])

    respond_to do |format|
      if @shipping_service.destroy
        format.json { render :json => {:result => true} }
      else
        format.json { render :json => {:result => false, :messages => @shipping_service.errors.messages} }
      end
    end
  end

  def edit_shipping_service
    @shipping_service = ShippingService.find(params[:id])
    if @shipping_service.shipping_method.code=="DPD-IE"
      @shipping_service.build_account_details
    end
    respond_to do |format|
      format.html {
        if request.xhr?
          render :partial => "setup/forms/shipping_methods/shipping_service", :locals => {:shipping_service => @shipping_service, :read_only => false}, :layout => false, :status => :created
        end
      }
    end
  end

  def new_shipping_service
    @shipping_service = ShippingService.new(:shipping_method_id => params[:id], :company_id => context_company_id)

    respond_to do |format|
      format.html {
        if request.xhr?
          render :partial => "setup/forms/shipping_methods/shipping_service", :locals => {:shipping_service => @shipping_service, :read_only => false}, :layout => false, :status => :created
        end
      }
    end
  end

  def update_shipping_service
    @shipping_service = ShippingService.find(params[:shipping_service][:id])
    respond_to do |format|
      if @shipping_service.update_attributes(params[:shipping_service])
        format.html {
          if request.xhr?
            render :partial => "setup/forms/shipping_methods/shipping_service", :locals => {:shipping_service => @shipping_service, :read_only => false}, :layout => false, :status => :created
          end
        }
      else
        format.html {
          if request.xhr?
            render :partial => "setup/forms/shipping_methods/shipping_service", :locals => {:shipping_service => @shipping_service, :read_only => false}, :layout => false, :status => :unprocessable_entity
          end
        }
      end
    end
  end

  def create_shipping_service
    @shipping_service = ShippingService.new(:shipping_method_id => params[:id], :company_id => context_company_id)
    respond_to do |format|
      if @shipping_service.update_attributes(params[:shipping_service])
        format.html {
          if request.xhr?
            render :partial => "setup/forms/shipping_methods/shipping_service", :locals => {:shipping_service => @shipping_service, :read_only => false}, :layout => false, :status => :created
          end
        }
      else
        format.html {
          if request.xhr?
            render :partial => "setup/forms/shipping_methods/shipping_service", :locals => {:shipping_service => @shipping_service, :read_only => false}, :layout => false, :status => :unprocessable_entity
          end
        }
      end
    end
  end

  def get_available_shipping_services
    @shipping_services = ShippingService.get_available_rate(params[:order_id], params[:weight], params[:comp_pack_type_id], params[:dimensions], session[:current_location_id])

    respond_to do |format|
      format.html {
        if request.xhr?
          render :partial => "order_shipments/available_shipping_services", :layout => false, :status => :created
        end
      }
    end
  end

  def get_fedex_rate
    order = Order.find(params[:order_id])
    begin
      rate = FedexSetting.get_rates(order, params[:weight], params[:fedex_data])
      result = "#{rate[0][:total_net_charge]}"
    rescue
      result = $!.inspect.to_s
    end

    respond_to do |format|
      format.json { render :json => result }
    end
  end
end
