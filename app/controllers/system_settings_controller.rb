class SystemSettingsController < ApplicationController
  add_breadcrumb I18n.t('breadcrumbs.home'), "/"

  # GET /customers
  # GET /customers.json
  def index
    add_breadcrumb I18n.t('breadcrumbs.system_settings'), system_settings_path, {:type => "page_title"}
    respond_to do |format|
      format.html # index.html.erb
      format.json { render :json => SystemSettingsDatatable.new(view_context, context_company_id) }
    end
  end

  # GET /system_settings/1
  # GET /system_settings/1.json
  def show
    @system_setting = SystemSetting.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @system_setting }
    end
  end

  # GET /system_settings/new
  # GET /system_settings/new.json
  def new
    @system_setting = SystemSetting.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @system_setting }
    end
  end

  # GET /system_settings/1/edit
  def edit
    @system_setting = SystemSetting.find(params[:id])
    company_setting = CompanySetting.find_by_company_id_and_system_setting_id(context_company_id, @system_setting.id)
    if company_setting.present?
      @system_setting.value = company_setting.value
    end
    respond_to do |format|
      format.html {
        if request.xhr?
          render :partial => "setup/forms/system_settings/system_settings_edit", :locals => {:system_setting => @system_setting, :show => false, :read_only => false}, :layout => false, :status => :created
        else
          redirect_to(@system_setting, :notice => "")
        end
      }
    end
  end

  # POST /system_settings
  # POST /system_settings.json
  def create
    @system_setting = SystemSetting.new(params[:system_setting])

    respond_to do |format|
      if @system_setting.save
        format.html { redirect_to @system_setting, notice: 'System setting was successfully created.' }
        format.json { render json: @system_setting, status: :created, location: @system_setting }
      else
        format.html { render action: "new" }
        format.json { render json: @system_setting.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /system_settings/1
  # PATCH/PUT /system_settings/1.json
  def update
    @system_setting = SystemSetting.find(params[:id])
    company_value = CompanySetting.find_or_initialize_by_company_id_and_system_setting_id(context_company_id, @system_setting.id)
    #if company_value.present?
    company_value.value = params[:system_setting][:value]
    company_value.save
    params[:system_setting].delete(:value)
    #end
    respond_to do |format|
      if @system_setting.update_attributes(params[:system_setting])
        format.html {
          if request.xhr?
            render :partial => "setup/forms/system_settings/system_settings_edit", :locals => {:system_setting => @system_setting, :read_only => false}, :layout => false, :status => :created
          end
        }
      else
        format.html {
          if request.xhr?
            render :partial => "setup/forms/system_settings/system_settings_edit", :locals => {:stock_location => @system_setting, :read_only => false}, :layout => false, :status => :unprocessable_entity
          end
        }
      end
    end
  end

  # DELETE /system_settings/1
  ## DELETE /system_settings/1.json
  #DESTROY NOT ALLOWED
  #def destroy
  #  @system_setting = SystemSetting.find(params[:id])
  #  @system_setting.destroy
  #
  #  respond_to do |format|
  #    format.html { redirect_to system_settings_url }
  #    format.json { head :no_content }
  #  end
  #end
end
