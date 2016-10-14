class OrderShippingDatatable

  delegate :params, :number_with_precision, :h, :link_to, :image_tag, :datatable_icon, :t, :number_to_currency, to: :@view

  def initialize(view, current_location)
    @view = view
    @current_location = current_location
  end

  def as_json(options = {})

    count = Order.where("orders.status = ?", Order::STATUS_WEIGHED).joins(:order_picks).where("order_picks.location_id = ?", @current_location).group('orders.id').all.count
    {
        sEcho: params[:sEcho].to_i,
        iTotalRecords: count,
        iTotalDisplayRecords: fetch_items.all.count,
        aaData: data,
        shipping_summary: shipping_summary
    }
  end

  private

  def shipping_summary
    shipping_data = {}

    data.map do |order|
      service = order[8]
      weight = order[5]
      if shipping_data[service].blank?
        shipping_data[service] = [0, 0]
      end

      shipping_data[service] = [
          (shipping_data[service][0] + weight.to_d),
          shipping_data[service][1] += 1
      ]

    end

    shipping_data.map { |k, v|
      avg_weight = (v[0].to_d / v[1].to_d) rescue 0
      {
          :service => k,
          :total_weight => (number_with_precision(v[0], :precision => 2) rescue 0),
          :units => v[1],
          :avg_weight => (number_with_precision(avg_weight, :precision => 2) rescue 0)
      } }
  end

  def data
    items.page(page).per(per_page).map do |order|
      check_box = "<input type='checkbox' name='check_pick_order' value=#{order.id} class='check_pick_order'/>"
      if order.override_shipping_service_id.blank?
        shipping_service = order.service
        courier = order.courier
      else
        service = ShippingService.find(order.override_shipping_service_id)
        shipping_service = service.name
        courier = service.shipping_method.name
      end

      country = Country.find_country_by_alpha2(order.country)


      [
          check_box,
          h(order.order_date.localtime),
          h(order.channel_order_id),
          h(order.customer_name),
          (country.name rescue ''),
          h(order.shipping_weight),
          number_to_currency(order.order_total),
          courier,
          shipping_service,
          h(order.shipment_error),
          datatable_icon({:class => 'edit-button', :id => "edit_order_#{order.id}"}),
          (order.highlight_colour rescue ''),
          (order.font_colour rescue '')
      ]
    end
  end

  def items

    @items ||= fetch_items
  end

  def fetch_items
    items = Order.select("orders.id, channels.name as channel_name, orders.channel_order_id, orders.shipment_error, orders.shipping_weight,
orders.order_date, orders.customer_id, orders.status, shipping_methods.name as courier, shipping_services.name as service,
orders.order_total, ca.country, orders.override_shipping_service_id,orders.channel_shipping_service_id, IF(ISNULL(ca.name), customers.full_name, ca.name) as customer_name,cs.highlight_colour, cs.font_colour").
        joins(:customer).
        joins('inner join customer_addresses ca on ca.id = orders.shipping_address_id').
        joins(:channel).
        joins(:shipping_service).
        joins(:shipping_method).
        joins(:order_picks).
        joins('left outer join channel_shipping_services cs on cs.id = orders.channel_shipping_service_id').
        group('orders.id').
        order("#{sort_column} #{sort_direction}").
        where("orders.status = ?", Order::STATUS_WEIGHED).
        where("order_picks.location_id = ?", @current_location)


    if params[:sSearch].present?
      items = items.where("orders.channel_order_id like :search or customers.full_name like :search or ca.name like :search", search: "%#{params[:sSearch]}%")
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
    columns = %w[orders.channel_order_id orders.order_date orders.channel_order_id customer_name]
    columns[params[:iSortCol_0].to_i]
  end

  def sort_direction
    params[:sSortDir_0] == "desc" ? "desc" : "asc"
  end

end

