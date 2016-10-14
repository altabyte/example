class ChannelsController < ApplicationController
  #load_and_authorize_resource

  def index
    respond_to do |format|
      format.json { render :json => ChannelsDatatable.new(view_context, context_company_id) }
    end
  end


  # GET /channels/new
  # GET /channels/new.json
  def new
    @channel = Channel.new

    respond_to do |format|
      format.html {
        if request.xhr?
          render :partial => "setup/forms/channel/new_channel", :layout => false, :status => :created
        end
      }
    end
  end

  # GET /channels/1/edit
  def edit
    @channel = Channel.find(params[:id])
    respond_to do |format|
      format.html {
        if request.xhr?
          render :partial => "setup/forms/channel/channel_edit", :locals => {:channel => @channel}, :layout => false, :status => :created
        else
          redirect_to(@channel, :notice => "")
        end
      }
    end
  end

  # POST /channels
  # POST /channels.json
  def create
    if params[:channel][:password_1_new].present?
      params[:channel][:password_1] = params[:channel][:password_1_new]

    end
    params[:channel].delete(:password_1_new)

    if params[:channel][:password_2_new].present?
      params[:channel][:password_2] = params[:channel][:password_2_new]

    end
    params[:channel].delete(:password_2_new)

    if params[:channel][:password_3_new].present?
      params[:channel][:password_3] = params[:channel][:password_3_new]

    end
    params[:channel].delete(:password_3_new)
    @channel = Channel.new(params[:channel])

    if @channel.company_id.blank?
      @channel.company_id = context_company_id
    end


    respond_to do |format|
      if @channel.save
        format.html {
          if request.xhr?
            render :partial => "setup/forms/channel/new_channel", :layout => false, :status => :created
          end
        }
      else
        format.html {
          if request.xhr?
            render :partial => "setup/forms/channel/new_channel", :layout => false, :status => :unprocessable_entity
          end
        }
      end
    end
  end

  # PATCH/PUT /channels/1
  # PATCH/PUT /channels/1.json
  def update
    @channel = Channel.find(params[:id])
    if params[:channel][:password_1_new].present?
      params[:channel][:password_1] = params[:channel][:password_1_new]

    end
    params[:channel].delete(:password_1_new)

    if params[:channel][:password_2_new].present?
      params[:channel][:password_2] = params[:channel][:password_2_new]

    end
    params[:channel].delete(:password_2_new)

    if params[:channel][:password_3_new].present?
      params[:channel][:password_3] = params[:channel][:password_3_new]

    end
    params[:channel].delete(:password_3_new)

    respond_to do |format|
      if @channel.update_attributes(params[:channel])
        format.html {
          if request.xhr?
            render :partial => "setup/forms/channel/channel_basic_details", :layout => false, :status => :created
          end
        }
      else
        format.html {
          if request.xhr?
            render :partial => "setup/forms/channel/channel_basic_details", :layout => false, :status => :unprocessable_entity
          end
        }
      end
    end
  end

  # DELETE /channels/1
  # DELETE /channels/1.json
  def destroy
    @channel = Channel.find(params[:id])
    @channel.destroy

    respond_to do |format|
      format.html { redirect_to channels_url }
      format.json { head :no_content }
    end
  end

  def list_channel_shipping_services
    respond_to do |format|
      format.json { render :json => ChannelShippingServicesDatatable.new(view_context, params[:id]) }
    end
  end

  def edit_shipping_service
    @channel_shipping_service = ChannelShippingService.find(params[:id])
    respond_to do |format|
      format.html {
        if request.xhr?
          render :partial => "setup/forms/channel/channel_shipping_service_edit", :locals => {:channel_shipping_service => @channel_shipping_service}, :layout => false, :status => :created
        else
          redirect_to(@channel_shipping_service, :notice => "")
        end
      }
    end
  end

  def update_shipping_service
    @channel_shipping_service = ChannelShippingService.find(params[:id])

    respond_to do |format|
      if @channel_shipping_service.update_attributes(params[:channel_shipping_service])
        format.html {
          if request.xhr?
            render :partial => "setup/forms/channel/channel_shipping_service_edit", :layout => false, :status => :created
          end
        }
      else
        format.html {
          if request.xhr?
            render :partial => "setup/forms/channel/channel_shipping_service_edit", :layout => false, :status => :unprocessable_entity
          end
        }
      end
    end
  end

  def destroy_shipping_service
    @shipping_service = ChannelShippingService.find(params[:id])

    respond_to do |format|
      if @shipping_service.destroy
        format.json { render :json => {:result => true} }
      else
        format.json { render :json => {:result => false, :messages => @shipping_service.errors.messages} }
      end
    end
  end


  def list_channel_statuses
    respond_to do |format|
      format.json { render :json => ChannelStatusesDatatable.new(view_context, params[:id]) }
    end
  end

  def edit_channel_status
    @channel_status = ChannelStatus.find(params[:id])
    respond_to do |format|
      format.html {
        if request.xhr?
          render :partial => "setup/forms/channel/channel_status_edit", :locals => {:channel_status => @channel_status}, :layout => false, :status => :created
        else
          redirect_to(@channel_status, :notice => "")
        end
      }
    end
  end

  def update_channel_status
    @channel_status = ChannelStatus.find(params[:id])

    respond_to do |format|
      if @channel_status.update_attributes(params[:channel_status])
        format.html {
          if request.xhr?
            render :partial => "setup/forms/channel/channel_status_edit", :layout => false, :status => :created
          end
        }
      else
        format.html {
          if request.xhr?
            render :partial => "setup/forms/channel/channel_status_edit", :layout => false, :status => :unprocessable_entity
          end
        }
      end
    end
  end

  def destroy_channel_status
    @channel_status = ChannelStatus.find(params[:id])

    respond_to do |format|
      if @channel_status.destroy
        format.json { render :json => {:result => true} }
      else
        format.json { render :json => {:result => false, :messages => @channel_status.errors.messages} }
      end
    end
  end

  def reload_log
    @channel = Channel.find(params[:id])

    respond_to do |format|
      format.html {
        if request.xhr?
          render :partial => "setup/forms/channel/channel_log", :locals => {:channel => @channel}, :layout => false, :status => :created
        end
      }
    end
  end


end
