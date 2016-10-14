class CustomersDatatable

  delegate :params, :h, :link_to, :image_tag, :datatable_icon, :t, to: :@view

  def initialize(view, company_id)
    @view = view
    @company_id = company_id
  end

  def as_json(options = {})
    if @company_id.present?
      total_count = Customer.where(:company_id => @company_id).count
    else
      total_count = Customer.count
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
          h(item.channel_name),
          h(item.full_name),
          h(item.email),
          datatable_icon({:class => 'edit-button', :id => "edit_customer_#{item.id}"})
      ]
    end
  end

  def items
    @items ||= fetch_items
  end

  def fetch_items
    items = Customer.select("customers.id, channels.name as channel_name, customers.full_name, customers.email").joins("inner join channels on customers.channel_id = channels.id").order("#{sort_column} #{sort_direction}")
    if @company_id.present?
      items = items.where(:company_id => @company_id)
    end

    if params[:sSearch].present?
      items = items.where("customers.full_name like :search or customers.email like :search", search: "%#{params[:sSearch]}%")
    end

    if params[:sSearch_1].present?
      items = items.where("channels.name = :status", status: "#{params[:sSearch_1]}")
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
    columns = %w[channels.name full_name email]
    columns[params[:iSortCol_0].to_i]
  end

  def sort_direction
    params[:sSortDir_0] == "desc" ? "desc" : "asc"
  end

end

