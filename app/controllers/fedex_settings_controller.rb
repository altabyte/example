class FedexSettingsController < ApplicationController
  # GET /fedex_settings
  # GET /fedex_settings.json
  def index
    #@fedex_settings = FedexSetting.search(params[:search]).page(params[:page]).per(15)
    if params[:search]
      @fedex_settings = FedexSetting.where('id LIKE ?', "#{params[:search]}%").order('id').page(params[:page]).per(15)
    else
      @fedex_settings = FedexSetting.order('id').page(params[:page]).per(15)
    end
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @fedex_settings }
    end
  end

  # GET /fedex_settings/1
  # GET /fedex_settings/1.json
  def show
    @fedex_setting = FedexSetting.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @fedex_setting }
    end
  end

  # GET /fedex_settings/new
  # GET /fedex_settings/new.json
  def new
    @fedex_setting = FedexSetting.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @fedex_setting }
    end
  end

  # GET /fedex_settings/1/edit
  def edit
    @fedex_setting = FedexSetting.find(params[:id])
  end

  # POST /fedex_settings
  # POST /fedex_settings.json
  def create
    @fedex_setting = FedexSetting.new(params[:fedex_setting])

    respond_to do |format|
      if @fedex_setting.save
        format.html { redirect_to @fedex_setting, notice: 'Fedex setting was successfully created.' }
        format.json { render json: @fedex_setting, status: :created, location: @fedex_setting }
      else
        format.html { render action: "new" }
        format.json { render json: @fedex_setting.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /fedex_settings/1
  # PATCH/PUT /fedex_settings/1.json
  def update
    @fedex_setting = FedexSetting.find(params[:id])

    if params[:fedex_setting][:password].blank?
      params[:fedex_setting].delete("password")
    end

    respond_to do |format|
      if @fedex_setting.update_attributes(params[:fedex_setting])
        format.html { redirect_to @fedex_setting, notice: 'Fedex setting was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @fedex_setting.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /fedex_settings/1
  # DELETE /fedex_settings/1.json
  def destroy
    @fedex_setting = FedexSetting.find(params[:id])
    @fedex_setting.destroy

    respond_to do |format|
      format.html { redirect_to fedex_settings_url }
      format.json { head :no_content }
    end
  end
end
