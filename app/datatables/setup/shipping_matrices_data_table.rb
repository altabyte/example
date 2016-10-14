class ShippingMatricesDataTable

  delegate :params, :h, :link_to, :link_to_function, :image_tag, :datatable_icon, :t, to: :@view

  def initialize(view, company_id)
    @view = view
    @company_id = company_id
  end

  def as_json(options = {})
    {
        sEcho: params[:sEcho].to_i,
        iTotalRecords: fetch_items.count,
        iTotalDisplayRecords: fetch_items.count,
        aaData: data
    }
  end

  private

  def data
    items.page(page).per(per_page).map do |item|
      [
          (Country.find_country_by_alpha2(item.country).name rescue ''),
          h(item.next_day),
          h(item.order_subtotal_from),
          h(item.order_subtotal_to),
          h(item.weight_from),
          h(item.weight_to),
          h(item.shipping_cost),
          item.shipping_service.name
      ]
    end
  end

  def items
    @items ||= fetch_items
  end

  def fetch_items
    items = ShippingMatrix.for_company(@company_id).
        order("#{sort_column} #{sort_direction}")
  end

  def page
    params[:iDisplayStart].to_i/per_page + 1
  end

  def per_page
    params[:iDisplayLength].to_i > 0 ? params[:iDisplayLength].to_i : 10
  end

  def sort_column
    columns = %w[country next_day order_subtotal_from order_subtotal_to weight_from weight_to shipping_cost shipping_cost]
    columns[params[:iSortCol_0].to_i]
  end

  def sort_direction
    params[:sSortDir_0] == "desc" ? "desc" : "asc"
  end

end
