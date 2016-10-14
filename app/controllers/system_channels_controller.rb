class SystemChannelsController < ApplicationController
  # GET /system_channels
  # GET /system_channels.json
  def index
    #@system_channels = SystemChannel.search(params[:search]).page(params[:page]).per(15)
    if params[:search]
      @system_channels = SystemChannel.where('id LIKE ?', "#{params[:search]}%").order('id').page(params[:page]).per(15)
    else
      @system_channels = SystemChannel.order('id').page(params[:page]).per(15)
    end
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @system_channels }
    end
  end

  # GET /system_channels/1
  # GET /system_channels/1.json
  def show
    @system_channel = SystemChannel.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render :json => @system_channel.to_json(:include => :system_channel_setting) }
    end
  end

  # GET /system_channels/new
  # GET /system_channels/new.json
  def new
    @system_channel = SystemChannel.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @system_channel }
    end
  end

  # GET /system_channels/1/edit
  def edit
    @system_channel = SystemChannel.find(params[:id])
  end

  # POST /system_channels
  # POST /system_channels.json
  def create
    @system_channel = SystemChannel.new(params[:system_channel])

    respond_to do |format|
      if @system_channel.save
        format.html { redirect_to @system_channel, notice: 'System channel was successfully created.' }
        format.json { render json: @system_channel, status: :created, location: @system_channel }
      else
        format.html { render action: "new" }
        format.json { render json: @system_channel.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /system_channels/1
  # PATCH/PUT /system_channels/1.json
  def update
    @system_channel = SystemChannel.find(params[:id])

    respond_to do |format|
      if @system_channel.update_attributes(params[:system_channel])
        format.html { redirect_to @system_channel, notice: 'System channel was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @system_channel.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /system_channels/1
  # DELETE /system_channels/1.json
  def destroy
    @system_channel = SystemChannel.find(params[:id])
    @system_channel.destroy

    respond_to do |format|
      format.html { redirect_to system_channels_url }
      format.json { head :no_content }
    end
  end
end
