class SystemSettingsDatatable

  delegate :params, :h, :link_to, :link_to_function, :image_tag, :datatable_icon, :t, to: :@view

  def initialize(view, company_id)
    @company_id = company_id
    @view = view
  end

  def as_json(options = {})
    total_count = SystemSetting.count

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
      if item.company_value.present?
        value =item.company_value
      else
        value = item.value
      end
      [
          h(item.setting_group),
          h(item.setting_code),
          h(item.setting_description),
          h(value),
          datatable_icon({:class => 'edit-button', :id => "edit_system_setting_#{item.id}"}),
      ]

    end
  end

  def items
    @items ||= fetch_items
  end

  def fetch_items
    items = SystemSetting.
        order("#{sort_column} #{sort_direction}").
        joins("LEFT OUTER JOIN company_settings cs on cs.system_setting_id = system_settings.id and cs.company_id = #{@company_id}").
        select("system_settings.*, cs.value as company_value")


    if params[:sSearch].present?
      items = items.where("setting_code like :status or setting_description like :status", status: "%#{params[:sSearch]}%")
    end

    if params[:sSearch_1].present?
      items = items.where("setting_group = :status", status: "#{params[:sSearch_1]}")
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
    columns = %w[setting_group setting_code setting_description]
    columns[params[:iSortCol_0].to_i]
  end

  def sort_direction
    params[:sSortDir_0] == "desc" ? "desc" : "asc"
  end

end
