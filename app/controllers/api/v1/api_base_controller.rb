module Api
  module V1
    class ApiBaseController < ActionController::Base
      #user_token
      #location_id
      #email
      before_filter :api_auth, :except => [:api_tokens]
      respond_to :xml, :json

      rescue_from Exception do |exception|
        response = {
            :result => false,
            :exception_message => exception.message
        }

        respond_with response, :location => nil, :status => :internal_server_error
      end

      def api_auth
        @user = User.find_by_authentication_token(params[:user_token])
        if @user.present?
          if params[:location_id].present?
            location = StockLocation.find(params[:location_id])
            if location.present?
              @location = location
            end
          end
          #user access
        else
          head :forbidden
        end
      end
    end
  end
end
