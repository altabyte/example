class CompanyLogsController < ApplicationController
  add_breadcrumb I18n.t('breadcrumbs.home'), "/"

  def index
    add_breadcrumb I18n.t('breadcrumbs.company_logs'), company_logs_path, {:type => "page_title"}
    log_level = params[:log_level]
    respond_to do |format|
      format.html # index.html.erb
      format.json { render :json => CompanyLogsDatatable.new(view_context, context_company_id, log_level) }
    end
  end

  def clear
    CompanyLog.where(:company_id => context_company_id).delete_all
    respond_to do |format|
      format.json { render :json => 'complete' }
    end
  end

  def mark_as_read
    CompanyLog.where(:company_id => context_company_id).update_all(:read => 1)
    respond_to do |format|
      format.json { render :json => 'complete' }
    end
  end

  #
  ## GET /company_logs/1
  ## GET /company_logs/1.json
  #def show
  #  @company_log = CompanyLog.find(params[:id])
  #
  #  respond_to do |format|
  #    format.html # show.html.erb
  #    format.json { render json: @company_log }
  #  end
  #end
  #
  ## GET /company_logs/new
  ## GET /company_logs/new.json
  #def new
  #  @company_log = CompanyLog.new
  #
  #  respond_to do |format|
  #    format.html # new.html.erb
  #    format.json { render json: @company_log }
  #  end
  #end
  #
  ## GET /company_logs/1/edit
  #def edit
  #  @company_log = CompanyLog.find(params[:id])
  #end
  #
  ## POST /company_logs
  ## POST /company_logs.json
  #def create
  #  @company_log = CompanyLog.new(params[:company_log])
  #
  #  respond_to do |format|
  #    if @company_log.save
  #      format.html { redirect_to @company_log, notice: 'Company log was successfully created.' }
  #      format.json { render json: @company_log, status: :created, location: @company_log }
  #    else
  #      format.html { render action: "new" }
  #      format.json { render json: @company_log.errors, status: :unprocessable_entity }
  #    end
  #  end
  #end
  #
  ## PATCH/PUT /company_logs/1
  ## PATCH/PUT /company_logs/1.json
  #def update
  #  @company_log = CompanyLog.find(params[:id])
  #
  #  respond_to do |format|
  #    if @company_log.update_attributes(params[:company_log])
  #      format.html { redirect_to @company_log, notice: 'Company log was successfully updated.' }
  #      format.json { head :no_content }
  #    else
  #      format.html { render action: "edit" }
  #      format.json { render json: @company_log.errors, status: :unprocessable_entity }
  #    end
  #  end
  #end
  #
  ## DELETE /company_logs/1
  ## DELETE /company_logs/1.json
  #def destroy
  #  @company_log = CompanyLog.find(params[:id])
  #  @company_log.destroy
  #
  #  respond_to do |format|
  #    format.html { redirect_to company_logs_url }
  #    format.json { head :no_content }
  #  end
  #end
end
