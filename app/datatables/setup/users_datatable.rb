class UsersDatatable

  delegate :params, :h, :link_to, :link_to_function, :image_tag, :datatable_icon, :t, to: :@view

  def initialize(view, company_id)
    @view = view
    @company_id = company_id
  end

  def as_json(options = {})
    if @company_id.present?
      total_count = User.by_company(@company_id).count
    else
      total_count = User.count
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
      item.id != User.current_user.id ? delete = datatable_icon({:class => 'delete-button', :id => "delete_user_#{item.id}"}) : delete = ""
      [
          h(item.name),
          h(item.email),
          h(item.role_name),
          datatable_icon({:class => 'edit-button', :id => "edit_user_#{item.id}"}),
          delete]
    end
  end

  def items
    @items ||= fetch_items
  end

  def fetch_items
    items = User.order("#{sort_column} #{sort_direction}").joins(:role).select('users.*, roles.name as role_name')

    unless User.is_super?
      items = items.where('users.company_id IS NOT NULL').where('roles.name != "SuperUser"')
    end

    if @company_id.present?
      items = items.by_company(@company_id)
    end

    if params[:sSearch].present?
      items = items.where("name like :name or email like :name", name: "%#{params[:sSearch]}%")
    end

    if params[:sSearch_1].present?
      role = Role.find_by_name(params[:sSearch_1])
      items = items.where(:role_id => role.id)
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
    columns = %w[users.name email]
    columns[params[:iSortCol_0].to_i]
  end

  def sort_direction
    params[:sSortDir_0] == "desc" ? "desc" : "asc"
  end

end

