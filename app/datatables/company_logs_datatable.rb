class CompanyLogsDatatable

  delegate :params, :h, :link_to, :link_to_function, :image_tag, :datatable_icon, :t, to: :@view

  def initialize(view, company_id, log_level=nil)
    @company_id = company_id
    @view = view
    @log_level = log_level
  end

  def as_json(options = {})
    if @company_id.present?
      total_count = CompanyLog.where(:company_id => @company_id).count
    else
      total_count = CompanyLog.count
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
      [
          h(item.log_level),
          h(item.date_timestamp),
          h(item.message),
          h(item.read)
      ]

    end
  end

  def items
    @items ||= fetch_items
  end

  def fetch_items
    items = CompanyLog.order("#{sort_column} #{sort_direction}")
    if @company_id.present?
      items = items.where(:company_id => @company_id)
    end

    if params[:sSearch_0].present?
      items = items.where("message like :message", message: "%#{params[:sSearch_1]}%")
    end

    if params[:sSearch_1].present?
      items = items.where("log_level = :status", status: "#{params[:sSearch_1]}")
    end

    if @log_level.present?
      items = items.where("log_level = ?", @log_level)
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
    columns = %w[log_level date_timestamp message]
    columns[params[:iSortCol_0].to_i]
  end

  def sort_direction
    params[:sSortDir_0] == "desc" ? "desc" : "asc"
  end

end
