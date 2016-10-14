class HomeController < ApplicationController
  skip_before_filter :check_location_set

  def index
    if params[:location_id].present?
      location = StockLocation.find(params[:location_id])
      if location.present?
        session[:current_location_name] = location.name
        session[:current_location_id] = location.id
        current_user.set_current_location(session[:current_location_id])
      end
    end

    if params[:location_name].present? and (params[:company_name].present? or current_user.company_id.present?)
      company = params[:company_name].present? ? Company.find_by_name(params[:company_name]) : Company.find(current_user.company_id)
      if company.present?
        location = StockLocation.find_by_name_and_company_id(params[:location_name], company.id)
        if location.present?
          session[:current_location_name] = location.name
          session[:current_location_id] = location.id
          #current_user.set_current_location(session[:current_location_id])
        end
      end
    end

    if session[:current_location_id].nil?
      redirect_to(:controller => :home, :action => :set_location)
    else
      if current_user.present?
        current_user.set_current_location(session[:current_location_id])
      end
      if current_user.default_landing_page.present? and current_user.default_landing_page != 'home'
        redirect_to(:controller => current_user.default_landing_page.to_sym, :action => :index)
      else
        redirect_to(:controller => :home, :action => :dashboard)
      end
    end
  end

  def check_for_new_orders
    max_order_id = 0
    if current_user
      max_order_id = current_user.max_order_id
    end
    respond_to do |format|
      format.json { render json: {:max_order_id => max_order_id} }
    end
  end


  def dashboard
    @data = Report.dashboard_data
  end

  def update_location
    if params[:stock_location_id].present?
      stock_location = StockLocation.find(params[:stock_location_id]).check_location_for(current_user)
      if stock_location
        session[:current_location_id] = stock_location.id
        session[:current_location_name] = stock_location.name
        session[:context_company_id] = stock_location.company_id
        current_user.set_current_location(stock_location.id)
        if current_user.default_landing_page.present?
          redirect_to(:controller => current_user.default_landing_page.to_sym, :action => :index)
        else
          redirect_to(:controller => :home, :action => :index)
        end
      else
        redirect_to({:controller => :home, :action => :set_location}, :flash => {:error => "You do not have access to this location"})
      end
    else
      redirect_to(:controller => :home, :action => :set_location)
    end
  end

  def information_panel
    #silence do
    respond_to do |format|
      format.html {
        render :partial => "layouts/information", :layout => false, :status => :created
      }
    end
    #end
  end


  def set_location
    @locations = StockLocation.joins(:stock_location_users).where("stock_location_users.user_id" => current_user).where('stock_only = 0 or stock_only IS NULL')

    if @locations.count == 1
      session[:current_location_id] = @locations.first.id
      session[:current_location_name] = @locations.first.name
      redirect_to(:controller => :home, :action => :index)
    else
      session[:current_location_id] = nil
      session[:current_location_name] = nil
    end
  end

  def release_notes

  end

  def scale_test
    @scale_ip_address = (StockLocation.find(session[:current_location_id]).scale_ip_address rescue '')
  end
end
