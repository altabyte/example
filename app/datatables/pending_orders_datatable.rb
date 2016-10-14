class PendingOrdersDatatable

  delegate :params, :h, :link_to, :image_tag, :datatable_icon, :t, to: :@view

  def initialize(view, company_id)
    @view = view
    @company_id = company_id
  end

  def as_json(options = {})
    {
        sEcho: params[:sEcho].to_i,
        iTotalRecords: PendingOrder.where(:company_id => @company_id).all.count,
        iTotalDisplayRecords: fetch_items.count,
        aaData: data
    }
  end

  private

  def data
    items.page(page).per(per_page).map do |item|
      if item.channel.present?
        name = item.channel.name
      else
        name =''
      end
      [
          name,
          h(item.created_at.localtime),
          item.reason_pending,
          datatable_icon({:class => 'show-button', :id => "show_payload_#{item.id}"})
      ]
    end
  end

  def items
    @items ||= fetch_items
  end

  def fetch_items
    items = PendingOrder.order("#{sort_column} #{sort_direction}").where(:company_id => @company_id)
    if params[:sSearch].present?
      items = items.where("order_payload like :search or pending_reason like :search", search: "%#{params[:sSearch]}%")
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
    columns = %w[created_at reason_pending]
    columns[params[:iSortCol_0].to_i]
  end

  def sort_direction
    params[:sSortDir_0] == "desc" ? "desc" : "asc"
  end

end

