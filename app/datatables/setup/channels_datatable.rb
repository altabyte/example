class ChannelsDatatable

  delegate :params, :h, :link_to, :image_tag, :datatable_icon, :t, to: :@view

  def initialize(view, company_id)
    @view = view
    @company_id = company_id
  end

  def as_json(options = {})
    if @company_id.present?
      total_count = Channel.where(:company_id => @company_id).count
    else
      total_count = Channel.count
    end

    {
        sEcho: params[:sEcho].to_i,
        iTotalRecords: total_count,
        iTotalDisplayRecords: fetch_items.length,
        aaData: data
    }
  end

  private

  def data
    items.page(page).per(per_page).map do |item|
      delete = ''
      delete = datatable_icon({:class => 'delete-button', :id => "delete_channel_#{item.id}"}) if item.order_count == 0
      [
          h(item.sc_name),
          h(item.name),
          datatable_icon({:class => 'edit-button', :id => "edit_channel_#{item.id}"}),
          delete
      ]
    end
  end

  def items
    @items ||= fetch_items
  end

  def fetch_items
    items = Channel.joins(:system_channel).order("#{sort_column} #{sort_direction}").
        joins('LEFT OUTER JOIN orders oh on oh.channel_id = channels.id').
        select('count(oh.id) as order_count, channels.*, system_channels.name as sc_name').group('channels.id')
    if @company_id.present?
      items = items.where(:company_id => @company_id)
    end


    if params[:sSearch].present?
      items = items.where("channels.name like :search or system_channels.name like :search", search: "%#{params[:sSearch]}%")
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
    columns = %w[sc_name channels.name]
    columns[params[:iSortCol_0].to_i]
  end

  def sort_direction
    params[:sSortDir_0] == "desc" ? "desc" : "asc"
  end

end

