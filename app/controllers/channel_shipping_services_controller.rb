class ChannelShippingServicesController < ApplicationController
  # GET /channel_shipping_services
  # GET /channel_shipping_services.json
  def index
    #@channel_shipping_services = ChannelShippingService.search(params[:search]).page(params[:page]).per(15)
    if params[:search]
      @channel_shipping_services = ChannelShippingService.where('shipping_text LIKE ?', "%#{params[:search]}%").order('id').page(params[:page]).per(15)
    else
      @channel_shipping_services = ChannelShippingService.order('id').page(params[:page]).per(15)
    end
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @channel_shipping_services }
      format.xml { send_data(@channel_shipping_services.to_xml(:include => :shipping_service)) }
    end
  end

  # GET /channel_shipping_services/1
  # GET /channel_shipping_services/1.json
  def show
    @channel_shipping_service = ChannelShippingService.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @channel_shipping_service }
    end
  end

  # GET /channel_shipping_services/new
  # GET /channel_shipping_services/new.json
  def new
    @channel_shipping_service = ChannelShippingService.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @channel_shipping_service }
    end
  end

  # GET /channel_shipping_services/1/edit
  def edit
    @channel_shipping_service = ChannelShippingService.find(params[:id])
  end

  # POST /channel_shipping_services
  # POST /channel_shipping_services.json
  def create
    @channel_shipping_service = ChannelShippingService.new(params[:channel_shipping_service])

    respond_to do |format|
      if @channel_shipping_service.save
        format.html { redirect_to @channel_shipping_service, notice: 'Channel shipping service was successfully created.' }
        format.json { render json: @channel_shipping_service, status: :created, location: @channel_shipping_service }
      else
        format.html { render action: "new" }
        format.json { render json: @channel_shipping_service.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /channel_shipping_services/1
  # PATCH/PUT /channel_shipping_services/1.json
  def update
    @channel_shipping_service = ChannelShippingService.find(params[:id])

    respond_to do |format|
      if @channel_shipping_service.update_attributes(params[:channel_shipping_service])
        format.html { redirect_to @channel_shipping_service, notice: 'Channel shipping service was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @channel_shipping_service.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /channel_shipping_services/1
  # DELETE /channel_shipping_services/1.json
  def destroy
    @channel_shipping_service = ChannelShippingService.find(params[:id])
    @channel_shipping_service.destroy

    respond_to do |format|
      format.html { redirect_to channel_shipping_services_url }
      format.json { head :no_content }
    end
  end

  def list_new_services

    @services = ChannelShippingService.
        joins(:channel).
        joins("inner join companies on companies.id = channels.company_id").
        where("shipping_service_id IS NULL").
        where("companies.id = ?", context_company_id)

    @services_count = @services.count
    @company_id = context_company_id

    respond_to do |format|
      format.html {
        if request.xhr?
          render :partial => "orders/new_shipping_services_panel", :layout => false, :status => :created
        end
      }
    end
  end


  def save_new_services

    params[:values].each do |value|
      service = ChannelShippingService.find(value[1][:service_id])
      if service.present?
        service.shipping_service_id = value[1][:shipping_service_id]
        service.save!
      end
    end

    @services = ChannelShippingService.
        joins(:channel).
        joins("inner join companies on companies.id = channels.company_id").
        where("shipping_service_id IS NULL").
        where("companies.id = ?", context_company_id)

    @services_count = @services.count
    @company_id = context_company_id


    respond_to do |format|
      format.html {
        if request.xhr?
          render :partial => "orders/new_shipping_services_panel", :layout => false, :status => :created
        end
      }
    end
  end

end
