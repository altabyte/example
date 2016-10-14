class ShippingServicesDatatable

  delegate :params, :h, :link_to, :link_to_function, :image_tag, :datatable_icon, :human_boolean, :t, to: :@view

  def initialize(view, method_id, current_user)
    @view = view
    @method_id = method_id
    @company_id = Thread.current[:company_id]
  end

  def as_json(options = {})
    {
        sEcho: params[:sEcho].to_i,
        iTotalRecords: fetch_items.count,
        iTotalDisplayRecords: fetch_items.count,
        aaData: data
    }
  end

  private

  def data
    items.page(page).per(per_page).map do |item|
      if item.location.present?
        location = item.location.name
      else
        location = ""
      end

      if item.has_channel_shipping_services?
        delete = ""
      else
        delete =datatable_icon({:class => 'delete-button', :id => "delete_shipping_service_#{item.id}"})
      end


      if item.shipping_method.code == "RM"
        [
            h(item.name),
            location,
            h(item.service_reference),
            h((item.royal_mail_service rescue nil)),
            h((item.royal_mail_service_class rescue nil)),
            h((item.royal_mail_service_format rescue nil)),
            h((item.royal_mail_service_enhancement rescue nil)),
            datatable_icon({:class => 'edit-button', :id => "edit_shipping_service_#{item.id}"}),
            delete
        ]
      elsif item.shipping_method.code == "FDX"
        [
            h(item.name),
            location,
            h(item.fedex_service_type),
            h(item.fedex_package_type),
            datatable_icon({:class => 'edit-button', :id => "edit_shipping_service_#{item.id}"}),
            delete
        ]
      elsif item.shipping_method.code == "DPD-IE"
        if item.dpd_service.present?
          dpd_svc = I18n.t("dpd_services.#{item.dpd_service}")
        else
          dpd_svc = ''
        end
        [
            h(item.name),
            location,
            h(item.integration_identifier),
            human_boolean(item.tracked),
            h(item.account_number),
            dpd_svc,
            datatable_icon({:class => 'edit-button', :id => "edit_shipping_service_#{item.id}"}),
            delete
        ]
      else
        [
            h(item.name),
            location,
            h(item.integration_identifier),
            human_boolean(item.tracked),
            h(item.account_number),
            datatable_icon({:class => 'edit-button', :id => "edit_shipping_service_#{item.id}"}),
            delete
        ]
      end
    end
  end

  def items
    @items ||= fetch_items
  end

  def fetch_items
    items = ShippingService.where(:shipping_method_id => @method_id).order("#{sort_column} #{sort_direction}")

    if @company_id.present?
      items=items.where(:company_id => @company_id)
    end

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
