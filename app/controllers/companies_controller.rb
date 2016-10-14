class CompaniesController < ApplicationController
  def clear_down_data
    begin
      if @current_user.valid_password?(params[:user_password])
        cd_data = Date.parse(params[:clear_down_date_timestamp])
        result = Order.cleardown_data(context_company_id, cd_data.to_formatted_s(:db))
        result = "Erased #{result[:orders]} Orders</br>Erased #{result[:reports]} Reports</br>Erased #{result[:customers]} Customers"
      else
        result = 'Password entered does not match your current password.'
      end
    rescue => esc
      result = "Error: #{esc.to_s}"
    end
    respond_to do |format|
      format.json { render json: {:message => result} }
    end
  end

  def status_change
    begin
      if @current_user.valid_password?(params[:user_password])
        cd_data = Date.parse(params[:status_change_date_timestamp])
        result = Order.change_status(context_company_id, cd_data.to_formatted_s(:db), params[:old_status], params[:new_status])
        result = "Updated #{result[:orders]} Statuses"
      else
        result = 'Password entered does not match your current password.'
      end
    rescue => esc
      result = "Error: #{esc.to_s}"
    end
    respond_to do |format|
      format.json { render json: {:message => result} }
    end
  end

  def update_basic_details
    @company = Company.find(params[:id])
    respond_to do |format|
      if @company.update_attributes(params[:company])
        format.html {
          if request.xhr?
            render :partial => "setup/basic_details", :locals => {:company => @company}, :layout => false, :status => :created
          end
        }
        format.json { render :json => {success: "Success"} }
        format.js {}
      else
        format.html {
          if request.xhr?
            render :partial => "setup/basic_details", :locals => {:company => @company}, :layout => false, :status => :unprocessable_entity
          end
        }
      end
    end
  end

  def update_fedex_settings
    @company = Company.find(params[:id])
    respond_to do |format|
      if @company.update_attributes(params[:company])
        format.html {
          if request.xhr?
            render :partial => "setup/fedex_settings", :locals => {:company => @company}, :layout => false, :status => :created
          end
        }
        format.json { render :json => {success: "Success"} }
        format.js {}
      else
        format.html {
          if request.xhr?
            render :partial => "setup/fedex_settings", :locals => {:company => @company}, :layout => false, :status => :unprocessable_entity
          end
        }
      end
    end
  end

  def list_exchange_rates
    respond_to do |format|
      format.json { render :json => ExchangeRatesDatatable.new(view_context, params[:id]) }
    end
  end

  def update_exchange_rate
    @exchange_rate = ExchangeRate.find(params[:id])
    respond_to do |format|
      if @exchange_rate.update_attributes(params[:exchange_rate])
        format.html {
          if request.xhr?
            render :partial => "setup/forms/exchange_rates/exchange_rate_edit", :locals => {:exchange_rate => @exchange_rate, :show => false, :read_only => false}, :layout => false, :status => :created
          end
        }
      else
        format.html {
          if request.xhr?
            render :partial => "setup/forms/exchange_rates/exchange_rate_edit", :locals => {:exchange_rate => @exchange_rate, :show => false, :read_only => false}, :layout => false, :status => :unprocessable_entity
          end
        }
      end
    end
  end

  def edit_exchange_rate
    @exchange_rate = ExchangeRate.find(params[:id])
    respond_to do |format|
      format.html {
        if request.xhr?
          render :partial => "setup/forms/exchange_rates/exchange_rate_edit", :locals => {:exchange_rate => @exchange_rate, :show => false, :read_only => false}, :layout => false, :status => :created
        end
      }
    end
  end

  def get_latest_exchange_rates
    response = ExchangeRate.get_latest(context_company_id)

    respond_to do |format|
      format.json { render json: {:result => response[:result], :message => response[:message]} }
    end
  end
end
