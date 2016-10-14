class CustomerAddressesDatatable
  delegate :params, :h, :link_to, :image_tag, :datatable_icon, :t, to: :@view

  def initialize(view, customer_id)
    @view = view
    @customer_id = customer_id
  end

  def as_json(options = {})
    count = CustomerAddress.where(:customer_id => @customer_id).count

    {
        sEcho: params[:sEcho].to_i,
        iTotalRecords: count,
        iTotalDisplayRecords: items.count,
        aaData: data
    }
  end

  private

  def data
    items.page(page).per(per_page).map do |item|
      [
          h(item.address_type),
          h(item.town),
          (Country.find_country_by_alpha2(item.country).name rescue ''),
          h(item.post_code),
          datatable_icon({:class => 'edit-button', :id => "edit_customer_address_#{item.id}"})
      ]
    end
  end

  def items
    @items ||= fetch_items
  end

  def fetch_items
    items = CustomerAddress.order("#{sort_column} #{sort_direction}").where(:customer_id => @customer_id)
    if params[:sSearch].present?
      items = items.where("town like :search or post_code like :search or address_1 like :search or address_2 like :search", search: "%#{params[:sSearch]}%")
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
    columns = %w[address_type town country post_code]
    columns[params[:iSortCol_0].to_i]
  end

  def sort_direction
    params[:sSortDir_0] == "desc" ? "desc" : "asc"
  end

end