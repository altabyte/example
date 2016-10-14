class ReportsDatatable

  delegate :params, :h, :link_to, :link_to_function, :image_tag, :datatable_icon, :t, to: :@view

  def initialize(view, company_id)
    @company_id = company_id
    @view = view
  end

  def as_json(options = {})
    if @company_id.present?
      total_count = Report.by_company(@company_id).count
    else
      total_count = Report.count
    end

    {
        sEcho: params[:sEcho].to_i,
        iTotalRecords: total_count,
        iTotalDisplayRecords: fetch_items.count,
        aaData: data
    }
  end

  private

  def data
    items.page(page).per(per_page).map do |item|
      if item.report_file.present?
        file = h(item.report_file)
        link = datatable_icon({:class => 'show-button', :id => "show_report_#{item.id}"})
      else
        file = ""
        link = ""
      end

      [
          h(item.report_type),
          h(item.date_time),
          h(item.user.name),
          file,
          link
      ]

    end
  end

  def items
    @items ||= fetch_items
  end

  def fetch_items
    items = Report.order("#{sort_column} #{sort_direction}").joins(:user)
    if @company_id.present?
      items = items.by_company(@company_id)
    end

    if params[:unopened] == 'true'
      items = items.where("opened_flag = 'N'")
    end

    if params[:sSearch_1].present?
      items = items.where("report_type = :status", status: "#{params[:sSearch_1]}")
    end

    items
  end

  def page
    params[:iDisplayStart].to_i/per_page + 1
  end

  def per_page
    params[:iDisplayLength].to_i > 0 ? params[:iDisplayLength].to_i : 10
  end

  def sort_column
    columns = %w[report_type date_time users.name report_file]
    columns[params[:iSortCol_0].to_i]
  end

  def sort_direction
    params[:sSortDir_0] == "desc" ? "desc" : "asc"
  end

end
