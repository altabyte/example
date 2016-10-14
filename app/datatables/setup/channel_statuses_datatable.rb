class ChannelStatusesDatatable

  delegate :params, :h, :link_to, :image_tag, :datatable_icon, :t, to: :@view

  def initialize(view, channel_id)
    @view = view
    @channel_id = channel_id
  end

  def as_json(options = {})
    total_count = ChannelStatus.where(:channel_id => @channel_id).count

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
      delete = datatable_icon({:class => 'delete-button', :id => "delete_channel_status_#{item.id}"}) if item.orders.blank?
      [
          h(item.status_name),
          h((I18n.t("statuses.#{item.status.to_s.downcase}") rescue '')),
          datatable_icon({:class => 'edit-button', :id => "edit_channel_status_#{item.id}"}),
          delete
      ]
    end
  end

  def items
    @items ||= fetch_items
  end

  def fetch_items
    items = ChannelStatus.order("#{sort_column} #{sort_direction}").where(:channel_id => @channel_id).select('channel_statuses.*')

    if params[:sSearch].present?
      items = items.where("status_name like :search or status like :search", search: "%#{params[:sSearch]}%")
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
    columns = %w[status_name status]
    columns[params[:iSortCol_0].to_i]
  end

  def sort_direction
    params[:sSortDir_0] == "desc" ? "desc" : "asc"
  end

end

