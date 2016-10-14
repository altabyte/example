class ItemsDatatable

  delegate :params, :h, :link_to, :image_tag, :datatable_icon, :t, to: :@view

  def initialize(view, company_id)
    @view = view
    @company_id = company_id
  end

  def as_json(options = {})

    if @company_id.present?
      count = Item.where(:company_id => @company_id).count
    else
      count = Item.count
    end
    {
        sEcho: params[:sEcho].to_i,
        iTotalRecords: count,
        iTotalDisplayRecords: fetch_items.count,
        aaData: data
    }
  end

  private

  def data
    items.map do |item|
      [
          h(item.sku),
          h(item.name),
          h(item.size),
          h(item.colour)
      ]
    end
  end

  def items
    @items ||= fetch_items
    @items = @items.page(page).per(per_page)
  end

  def fetch_items
    items = Item.select("*")

    if @company_id.present?
      items = items.where(:company_id => @company_id)
    end

    if params[:sSearch].present?
      items = items.where("sku like :search or name like :search or size like :search or colour like :search", search: "%#{params[:sSearch]}%")
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
    columns = %w[sku name size colour]
    columns[params[:iSortCol_0].to_i]
  end

  def sort_direction
    params[:sSortDir_0] == "desc" ? "desc" : "asc"
  end

end

