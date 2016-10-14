class FedexShipmentsController < ApplicationController
  # GET /fedex_shipments
  # GET /fedex_shipments.json
  def index
    add_breadcrumb I18n.t('breadcrumbs.home'), "/"
    add_breadcrumb I18n.t('breadcrumbs.fedex_shipments'), fedex_shipments_path, {:type => "page_title"}
    respond_to do |format|
      format.html # index.html.erb
      format.json { render :json => FedexShipmentsDatatable.new(view_context, context_company_id) }
    end
  end

  def show
    @label = FedexShipment.find(params[:id])

    if @label.present? and @label.label.present?
      @label.printed_flag = 1
      @label.save!
      send_file(@label.label.path,
                :filename => @label.label_file_name,
                :type => 'application/pdf',
                :disposition => 'inline')
    else
      Rails.logger.info "reports_controller::show Error: no retail_report found."
    end
  end


end
