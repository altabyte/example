require "net/http"
require "uri"
class ShipmentCheckDatatable

  delegate :params, :h, :link_to, :image_tag, :datatable_icon, :status_change_select, :sagepay_display, :image_tag, :t, to: :@view

  def initialize(view, current_location)
    @view = view
    @current_location = current_location
  end

  def as_json(options = {})

    {
        sEcho: params[:sEcho].to_i,
        iTotalRecords: fetch_items.length,
        iTotalDisplayRecords: items.length,
        aaData: data
    }
  end

  private

  def data
    items.page(page).per(per_page).map do |order|
      [
          order.id,
          order.channel_order_id,
          h(order.os_created.localtime),
          order.shipment_check_failed
      ]
    end
  end

  def items
    @items ||= fetch_items
  end

  def fetch_items
    Order.select("orders.*, order_shipments.created_at as os_created").
        where("status like 'SHIPMENT_%' or status = ?",Order::STATUS_COMPLETE).
        where('orders.tracking_details IS NOT NULL').
        where('shipment_check_failed != 999 or shipment_check_failed IS NULL').
        where("order_shipments.stock_location_id =?", @current_location).
        order('order_shipments.created_at desc').
        group('orders.id').
        joins(:order_shipments)

  end

  def page
    params[:iDisplayStart].to_i/per_page + 1
  end

  def per_page
    params[:iDisplayLength].to_i > 0 ? params[:iDisplayLength].to_i : 10
  end

  def sort_column
    columns = %w[]
    columns[params[:iSortCol_0].to_i]
  end

  def sort_direction
    params[:sSortDir_0] == "desc" ? "desc" : "asc"
  end

end

