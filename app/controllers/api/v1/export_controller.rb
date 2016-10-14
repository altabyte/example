module Api
  module V1
    class ExportController < ApiBaseController
      def export
        if params[:export_type] and @user.company_id.present?
          return_data = ''

          case params[:export_type]
            when 'ORDER'
              return_data = ExportOrders.get_export_file(params, @user.company_id)
            when 'ORDER_LIST'
              return_data = ExportOrders.get_export_order_list(params, @user.company_id)
          end

          respond_to do |format|
            format.xml { render :xml => return_data }
          end

        else
        end
      end
    end
  end
end