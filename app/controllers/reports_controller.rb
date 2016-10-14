class ReportsController < ApplicationController
  add_breadcrumb I18n.t('breadcrumbs.home'), "/"

  def index
    add_breadcrumb I18n.t('breadcrumbs.reports'), reports_path, {:type => "page_title"}
    respond_to do |format|
      format.html # index.html.erb
      format.json { render :json => ReportsDatatable.new(view_context, context_company_id) }
    end
  end

  def show
    @report = Report.find(params[:id])

    if @report.present? and @report.report_file.present?
      @report.opened_flag = "Y"
      @report.save!
      send_file(@report.report_file.current_path,
                :filename => @report.report_file,
                :type => 'application/pdf',
                :disposition => 'inline')
    else
      Rails.logger.info "reports_controller::show Error: no retail_report found."
    end
  end

  def last
    @report = Report.find_last_by_user_id(current_user.id)

    if @report.present? and @report.report_file.present?
      @report.opened_flag = "Y"
      @report.save!
      send_file(@report.report_file.current_path,
                :filename => @report.report_file,
                :type => 'application/pdf',
                :disposition => 'inline')
    else
      Rails.logger.info "reports_controller::show Error: no retail_report found."
    end
  end
end
