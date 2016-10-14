class ShippingDestinationsDatatable

  delegate :params, :h, :link_to, :link_to_function, :image_tag, :datatable_icon, :t, to: :@view

  def initialize(view, company_id)
    @company_id = company_id
    @view = view
  end

  def as_json(options = {})
    if @company_id.present?
      total_count = ShippingDestination.where(:company_id => @company_id).count
    else
      total_count = ShippingDestination.count
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
      delete =datatable_icon({:class => 'delete-button', :id => "delete_shipping_destination_#{item.id}"})
      [
          h(Country.find_country_by_alpha2(item.country_code).name),
          h(item.item_weight_required),
          h(item.item_county_of_origin_required),
          h(item.harmonization_code_required),
          delete
      ]

    end
  end

  def items
    @items ||= fetch_items
  end

  def fetch_items
    items = ShippingDestination.order("#{sort_column} #{sort_direction}")

    if @company_id.present?
      items = items.where(:company_id => @company_id)
    end

    if params[:sSearch].present?
      items = items.where("country_code like :country_code", country_code: "%#{params[:sSearch]}%")
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
    columns = %w[country_code item_weight_required item_county_of_origin_required harmonization_code_required]
    columns[params[:iSortCol_0].to_i]
  end

  def sort_direction
    params[:sSortDir_0] == "desc" ? "desc" : "asc"
  end

end
