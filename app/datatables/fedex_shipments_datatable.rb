class FedexShipmentsDatatable

  delegate :params, :h, :link_to, :link_to_function, :image_tag, :datatable_icon, :t, to: :@view

  def initialize(view, company_id)
    @company_id = company_id
    @view = view
  end

  def as_json(options = {})
    if @company_id.present?
      total_count = FedexShipment.for_company(@company_id).count
    else
      total_count = FedexShipment.count
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
      if item.label_file_name.present?
        link = datatable_icon({:class => 'show-button', :id => "get_fedex_label_#{item.id}"})
      else
        link = ""
      end

      opened = item.printed_flag ? 'Yes' : 'No'

      [
          h(item.channel_order_id),
          h(item.created_at),
          opened,
          link
      ]

    end
  end

  def items
    @items ||= fetch_items
  end

  def fetch_items
    items = FedexShipment.joins(:order).select('orders.channel_order_id, `fedex_shipments`.*').
        order("#{sort_column} #{sort_direction}")
    if @company_id.present?
      items = items.for_company(@company_id)
    end

    if params[:sSearch_1].present? and params[:sSearch_1] == 'UNPRINTED' or params[:sSearch_1].blank?
      items = items.where("printed_flag = 0")
    elsif params[:sSearch_1] == 'PRINTED'
      items = items.where("printed_flag = 1")
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
    columns = %w[channel_order_id created_at printed_flag]
    columns[params[:iSortCol_0].to_i]
  end

  def sort_direction
    params[:sSortDir_0] == "desc" ? "desc" : "asc"
  end

end
