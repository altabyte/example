class CustomerOrderHisDatatable
  delegate :params, :number_to_currency, :h, :link_to, :image_tag, :datatable_icon, :t, to: :@view

  def initialize(view, item_id)
    @view = view
    @item_id = item_id
  end

  def as_json(options = {})
    count = items.count

    {
        sEcho: params[:sEcho].to_i,
        iTotalRecords: count,
        iTotalDisplayRecords: count,
        aaData: data
    }
  end

  private

  def data
    items.map do |item|
      subtotal = item.order_total - item.shipping_cost
      subtotal = number_to_currency(subtotal)
      [
          h(item.order_date.localtime),
          h(item.channel_order_id),
          h(subtotal),
          h(item.status),
          datatable_icon({:class => 'show-button', :id => "show_order_info_#{item.id}"})
      ]
    end
  end

  def items
    @items ||= fetch_items
    @items = @items.page(page).per(per_page)
  end

  def fetch_items
    items = Order.where(:customer_id => @item_id).order("#{sort_column} #{sort_direction}")
  end

  def page
    params[:iDisplayStart].to_i/per_page + 1
  end

  def per_page
    params[:iDisplayLength].to_i > 0 ? params[:iDisplayLength].to_i : 10
  end

  def sort_column
    columns = %w[order_date channel_order_id order_total status]
    columns[params[:iSortCol_0].to_i]
  end

  def sort_direction
    params[:sSortDir_0] == "desc" ? "desc" : "asc"
  end

end