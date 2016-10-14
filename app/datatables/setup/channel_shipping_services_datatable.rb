class ChannelShippingServicesDatatable

  delegate :params, :h, :link_to, :image_tag, :datatable_icon, :t, to: :@view

  def initialize(view, channel_id)
    @view = view
    @channel_id = channel_id
  end

  def as_json(options = {})
    total_count = ChannelShippingService.where(:channel_id => @channel_id).count

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
      delete = ''
      delete = datatable_icon({:class => 'delete-button', :id => "delete_channel_shipping_service_#{item.id}"}) if item.orders.blank?
      [
          h(item.shipping_text),
          h((item.shipping_service.name rescue '')),
          h(item.useable_text),
          datatable_icon({:class => 'edit-button', :id => "edit_channel_shipping_service_#{item.id}"}),
          delete
      ]
    end
  end

  def items
    @items ||= fetch_items
  end

  def fetch_items
    items = ChannelShippingService.joins('LEFT OUTER JOIN shipping_services on shipping_services.id = channel_shipping_services.shipping_service_id').joins(:channel).order("#{sort_column} #{sort_direction}").where(:channel_id => @channel_id)

    if params[:sSearch].present?
      items = items.where("channel_shipping_services.shipping_text like :search or channel_shipping_services.useable_text like :search or shipping_services.name", search: "%#{params[:sSearch]}%")
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
    columns = %w[shipping_text shipping_services.name useable_text]
    columns[params[:iSortCol_0].to_i]
  end

  def sort_direction
    params[:sSortDir_0] == "desc" ? "desc" : "asc"
  end

end

