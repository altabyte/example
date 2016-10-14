class CompaniesDatatable

  delegate :params, :h, :link_to, :image_tag, :datatable_icon, :t, to: :@view

  def initialize(view)
    @view = view
  end

  def as_json(options = {})
    {
        sEcho: params[:sEcho].to_i,
        iTotalRecords: Company.all.count,
        iTotalDisplayRecords: fetch_items.count,
        aaData: data
    }
  end

  private

  def data
    items.page(page).per(per_page).map do |item|
      delete = ''
      delete = datatable_icon({:class => 'delete-button', :id => "delete_company_#{item.id}"}) if item.users.blank?
      [
          h(item.name),
          item.address_to_html,
          datatable_icon({:class => 'edit-button', :id => "edit_company_#{item.id}"}),
          delete
      ]
    end
  end

  def items
    @items ||= fetch_items
  end

  def fetch_items
    items = Company.order("#{sort_column} #{sort_direction}")
    if params[:sSearch].present?
      items = items.where("name like :search", search: "%#{params[:sSearch]}%")
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
    columns = %w[name]
    columns[params[:iSortCol_0].to_i]
  end

  def sort_direction
    params[:sSortDir_0] == "desc" ? "desc" : "asc"
  end

end

