class ChannelStatusesController < ApplicationController
  # GET /channel_statuses
  # GET /channel_statuses.json
  def index
    #@channel_statuses = ChannelStatus.search(params[:search]).page(params[:page]).per(15)
    if params[:search]
      @channel_statuses = ChannelStatus.where('id LIKE ?', "#{params[:search]}%").order('id').page(params[:page]).per(15)
    else
      @channel_statuses = ChannelStatus.order('id').page(params[:page]).per(15)
    end
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @channel_statuses }
    end
  end

  # GET /channel_statuses/1
  # GET /channel_statuses/1.json
  def show
    @channel_status = ChannelStatus.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @channel_status }
    end
  end

  # GET /channel_statuses/new
  # GET /channel_statuses/new.json
  def new
    @channel_status = ChannelStatus.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @channel_status }
    end
  end

  # GET /channel_statuses/1/edit
  def edit
    @channel_status = ChannelStatus.find(params[:id])
  end

  # POST /channel_statuses
  # POST /channel_statuses.json
  def create
    @channel_status = ChannelStatus.new(params[:channel_status])

    respond_to do |format|
      if @channel_status.save
        format.html { redirect_to @channel_status, notice: 'Channel status was successfully created.' }
        format.json { render json: @channel_status, status: :created, location: @channel_status }
      else
        format.html { render action: "new" }
        format.json { render json: @channel_status.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /channel_statuses/1
  # PATCH/PUT /channel_statuses/1.json
  def update
    @channel_status = ChannelStatus.find(params[:id])

    respond_to do |format|
      if @channel_status.update_attributes(params[:channel_status])
        format.html { redirect_to @channel_status, notice: 'Channel status was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @channel_status.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /channel_statuses/1
  # DELETE /channel_statuses/1.json
  def destroy
    @channel_status = ChannelStatus.find(params[:id])
    @channel_status.destroy

    respond_to do |format|
      format.html { redirect_to channel_statuses_url }
      format.json { head :no_content }
    end
  end
end
