class StockLocationUsersDatatable

  delegate :params, :h, :link_to, :image_tag, :datatable_icon, :t, to: :@view

  def initialize(view, stock_location_id)
    @view = view
    @stock_location_id = stock_location_id
  end

  def as_json(options = {})
    locations = StockLocationUser.where(:stock_location_id => @stock_location_id).joins(:user)

    unless User.is_super?
      locations = locations.where('users.company_id IS NOT NULL')
    end
    {
        sEcho: params[:sEcho].to_i,
        iTotalRecords: locations.count,
        iTotalDisplayRecords: fetch_items.count,
        aaData: data
    }
  end

  private

  def data
    items.map do |item|
      [
          h(item.name),
          h(item.email),
          datatable_icon({:class => 'delete-button', :id => "delete_stock_location_user_#{item.id}"})
      ]
    end
  end

  def items
    @items ||= fetch_items
    @items = @items.page(page).per(per_page)
  end

  def fetch_items
    items = StockLocationUser.select("stock_location_users.*, users.name, users.email").joins(:user).where(:stock_location_id => @stock_location_id)

    unless User.is_super?
      items = items.where('users.company_id IS NOT NULL')
    end

    if params[:sSearch].present?
      items = items.where("users.name like :search or users.email like :search", search: "%#{params[:sSearch]}%")
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
    columns = %w[users.name users.email]
    columns[params[:iSortCol_0].to_i]
  end

  def sort_direction
    params[:sSortDir_0] == "desc" ? "desc" : "asc"
  end

end

