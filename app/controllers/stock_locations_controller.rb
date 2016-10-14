class StockLocationsController < ApplicationController
  add_breadcrumb I18n.t('breadcrumbs.home'), "/"

  # GET /customers
  # GET /customers.json
  def index
    add_breadcrumb I18n.t('breadcrumbs.stock_locations'), stock_locations_path, {:type => "page_title"}
    respond_to do |format|
      format.html # index.html.erb
      format.json { render :json => StockLocationsDatatable.new(view_context, context_company_id) }
    end
  end

  # GET /stock_locations/new
  # GET /stock_locations/new.json
  def new
    @stock_location = StockLocation.new

    respond_to do |format|
      format.html {
        if request.xhr?
          render :partial => "setup/forms/stock_locations/stock_location", :locals => {:stock_location => @stock_location, :read_only => false}, :layout => false, :status => :created
        end
      }
    end
  end

  # GET /stock_locations/1/edit
  def edit
    @stock_location = StockLocation.find(params[:id])
    respond_to do |format|
      format.html {
        if request.xhr?
          render :partial => "setup/forms/stock_locations/stock_location_edit", :locals => {:stock_location => @stock_location, :show => false, :read_only => false}, :layout => false, :status => :created
        else
          redirect_to(@stock_location, :notice => "")
        end
      }
    end
  end

  # POST /stock_locations
  # POST /stock_locations.json
  def create
    if params[:stock_location][:ftp_password_new].present?
      params[:stock_location][:ftp_password] = params[:stock_location][:ftp_password_new]
    end
    params[:stock_location].delete(:ftp_password_new)
    @stock_location = StockLocation.new(params[:stock_location])
    @stock_location.company_id = context_company_id

    respond_to do |format|
      if @stock_location.update_attributes(params[:stock_location])
        format.html {
          if request.xhr?
            render :partial => "setup/forms/stock_locations/stock_location", :locals => {:stock_location => @stock_location, :read_only => false}, :layout => false, :status => :created
          end
        }
      else
        format.html {
          if request.xhr?
            render :partial => "setup/forms/stock_locations/stock_location", :locals => {:stock_location => @stock_location, :read_only => false}, :layout => false, :status => :unprocessable_entity
          end
        }
      end
    end
  end

  # PATCH/PUT /stock_locations/1
  # PATCH/PUT /stock_locations/1.json
  def update
    if params[:stock_location][:ftp_password_new].present?
      params[:stock_location][:ftp_password] = params[:stock_location][:ftp_password_new]
    end
    params[:stock_location].delete(:ftp_password_new)
    @stock_location = StockLocation.find(params[:id])

    respond_to do |format|
      if @stock_location.update_attributes(params[:stock_location])
        format.html {
          if request.xhr?
            render :partial => "setup/forms/stock_locations/stock_location_edit", :locals => {:stock_location => @stock_location, :read_only => false}, :layout => false, :status => :created
          end
        }
      else
        format.html {
          if request.xhr?
            render :partial => "setup/forms/stock_locations/stock_location_edit", :locals => {:stock_location => @stock_location, :read_only => false}, :layout => false, :status => :unprocessable_entity
          end
        }
      end
    end
  end

  # DELETE /stock_locations/1
  # DELETE /stock_locations/1.json
  def destroy
    @stock_location = StockLocation.find(params[:id])
    @stock_location.destroy

    respond_to do |format|
      format.html { redirect_to stock_locations_url }
      format.json { head :no_content }
    end
  end


  def list_stock_location_users
    respond_to do |format|
      format.json { render :json => StockLocationUsersDatatable.new(view_context, params[:id]) }
    end
  end

  def new_stock_location_user
    @stock_location_user = StockLocationUser.new
    @stock_location_user.stock_location_id = params[:id]

    respond_to do |format|
      format.html {
        if request.xhr?
          render :partial => "setup/forms/stock_locations/stock_location_user", :locals => {:stock_location_user => @stock_location_user, :read_only => false}, :layout => false, :status => :created
        end
      }
    end
  end

  def create_stock_location_user
    @stock_location_user = StockLocationUser.new
    @stock_location_user.stock_location_id = params[:id]

    respond_to do |format|
      if @stock_location_user.update_attributes(params[:stock_location_user])
        format.html {
          if request.xhr?
            render :partial => "setup/forms/stock_locations/stock_location_user", :locals => {:stock_location_user => @stock_location_user, :read_only => false}, :layout => false, :status => :created
          end
        }
      else
        format.html {
          if request.xhr?
            render :partial => "setup/forms/stock_locations/stock_location_user", :locals => {:stock_location_user => @stock_location_user, :read_only => false}, :layout => false, :status => :unprocessable_entity
          end
        }
      end
    end
  end

  def delete_stock_location_user
    stock_location_user = StockLocationUser.find(params[:id])
    stock_location_user.destroy

    respond_to do |format|
      format.html { redirect_to stock_locations_url }
      format.json { head :no_content }
    end

  end
end
