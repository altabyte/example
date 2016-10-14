class PackagingTypeDatatable

  delegate :params, :h, :link_to, :link_to_function, :image_tag, :datatable_icon, :t, to: :@view

  def initialize(view, company_id)
    @company_id = company_id
    @view = view
  end

  def as_json(options = {})
    if @company_id.present?
      total_count = CompanyPackagingType.where(:company_id => @company_id).count
    else
      total_count = CompanyPackagingType.count
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
      delete = datatable_icon({:class => 'delete-button', :id => "delete_packaging_type_#{item.id}"})
      pck_size = ""
      pck_size = "#{item.width}/#{item.height}/#{item.length}" if item.width.present?
      [
          h(item.name),
          pck_size,
          delete
      ]

    end
  end

  def items
    @items ||= fetch_items
  end

  def fetch_items
    items = CompanyPackagingType.order("#{sort_column} #{sort_direction}")

    if @company_id.present?
      items = items.where(:company_id => @company_id)
    end

    if params[:sSearch].present?
      items = items.where("name like :name", name: "%#{params[:sSearch]}%")
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
