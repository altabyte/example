class ShippingMatricesController < ApplicationController
  # GET /shipping_matrices
  # GET /shipping_matrices.json
  def index
    respond_to do |format|
      format.html # index.html.erb
      format.json { render :json => ShippingMatricesDataTable.new(view_context, context_company_id) }
    end
  end

  def download_file

    csv = ShippingMatrix.get_matrix_file(context_company_id)

    respond_to do |format|
      format.csv { send_data csv,
                             :filename => "shipping_matrices.csv",
                             :disposition => "attachment" }
    end

  end

  def import_file
    begin
      if params[:file].present?
        file = params[:file]
        result = ShippingMatrix.import_matrix_file(context_company_id, file)
      else
        result = {:success => false, :message => "#{t('shipping_matrices.import.no_file_selected')}"}
      end
    rescue Exception => exception
      result = {:success => false, :message => "#{t('shipping_matrices.import.import_error')}: #{exception.to_s}"}
    end

    respond_to do |format|
      if result[:success]
        format.json { head :ok }
      else
        format.json { render :json => result[:message], status: :unprocessable_entity }
      end
    end
  end
end
