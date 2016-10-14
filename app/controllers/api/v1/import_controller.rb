module Api
  module V1
    class ImportController < ApiBaseController
      def submit
        if params[:import_type]
          return_data = ''
          if @user.company_id.present?
            case params[:import_type]
              when 'ITEM'
                return_data = ImportItems.process_import_file(request.raw_post, @user.company_id)
              when 'ORDER'
                return_data = ImportOrder.process_import_file(request.raw_post, @user.company_id)
              when 'STOCK'
                return_data = ImportStock.process_import_file(request.raw_post, @user.company_id)
              when 'INVENTORY'
                return_data = ImportInventory.process_import_file(request.raw_post, @user.company_id)
              when 'TRACKING'
                return_data = ImportTracking.process_import_file(request.raw_post, @user.company_id)
              else
                return_data = {:success => false, :message => 'Unknown Import Type'}
            end
          else
            case params[:import_type]
              when 'CONFIG'
                return_data = ImportConfiguration.process_import_file(request.raw_post)
              else
                return_data = {:success => false, :message => 'Unknown Import Type'}
            end
          end

          respond_to do |format|
            format.xml { render :xml => return_data }
            format.json { render :json => return_data }
          end

        else
        end
      end
    end
  end
end