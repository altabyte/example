class ApplicationController < ActionController::Base


  before_filter :authenticate_user_from_token!
  before_filter :authenticate_user!
  before_filter :check_location_set


  before_filter { |c| User.current_user = c.current_user }
  before_filter :set_variables
  around_filter :do_with_current_user

  helper :all
  protect_from_forgery

  def do_with_current_user
    Rails.logger.info "setting current company thread to #{context_company_id}"
    Thread.current[:company_id] = context_company_id if context_company_id.present?
    begin
      yield
    ensure
      Thread.current[:company_id] = nil
    end
  end

  def check_location_set
    if controller_name == 'password_expired'

    elsif controller_name == 'sessions'
      if params[:location_id].present?
        location = StockLocation.find(params[:location_id])
        if location.present?
          session[:current_location_name] = location.name
          session[:current_location_id] = location.id
        end
      end

      if params[:location_name].present? and (params[:company_name].present? or current_user.present?)
        company = params[:company_name].present? ? Company.find_by_name(params[:company_name]) : Company.find(current_user.company_id)
        if company.present?
          location = StockLocation.find_by_name_and_company_id(params[:location_name], company.id)
          if location.present?
            session[:current_location_name] = location.name
            session[:current_location_id] = location.id
          end
        end
      end

      if params[:action] != 'destroy' and current_user.present?
        if session[:current_location_id].present?
          session[:context_company_id] = StockLocation.find(session[:current_location_id]).name
          redirect_to('/home')
        else
          redirect_to('/set_location')
        end
      end

    elsif current_user.present? and session[:current_location_id].blank?
      redirect_to('/set_location')
    end
  end

  def context_company_id
    company_id = User.current_user.company_id rescue nil
    if company_id.blank? and session[:context_company_id].present?
      company_id = session[:context_company_id]
    end
    company_id
  end

  def context_company
    Company.find(context_company_id)
  end

  def context_location
    User.current_user.stock_location
  end


  private
  def set_variables
    @current_user = User.current_user
    @user_company = @current_user.company rescue nil
    @current_location = StockLocation.find(session[:current_location_id]) rescue nil
    @context_company_id = context_company_id
  end

  def authenticate_user_from_token!
    user_email = params[:email].presence
    user = user_email && User.find_by_email(user_email)

    # Notice how we use Devise.secure_compare to compare the token
    # in the database with the token given in the params, mitigating
    # timing attacks.
    if user && Devise.secure_compare(user.authentication_token, params[:user_token])
      sign_in user, store: true
      #redirect_to ('/home')
    end
  end
end
