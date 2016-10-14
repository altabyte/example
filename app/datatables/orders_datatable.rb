require "net/http"
require "uri"
class OrdersDatatable

  delegate :params, :h, :link_to, :image_tag, :datatable_icon, :status_change_select, :sagepay_display, :image_tag, :t, to: :@view

  def initialize(view, show, company_id, current_user)
    @view = view
    @show = show
    @company_id = company_id
    @enable_sagepay = SystemSetting.check_setting('enable_sagepay_integration', false, @company_id)
    @current_user = current_user
    @can_change_status = (@current_user.check_role?("SuperUser") or @current_user.check_role?("Admin"))
  end

  def as_json(options = {})
    total_count = Order.joins(:customer).joins(:channel).joins("left outer join order_fraud_scores on order_fraud_scores.order_id = orders.id").where(:company_id => @company_id).count
    {
        sEcho: params[:sEcho].to_i,
        iTotalRecords: total_count,
        iTotalDisplayRecords: fetch_items.length,
        aaData: data
    }
  end

  private

  def data
    items.page(page).per(per_page).map do |orders|
      if @enable_sagepay
        sagepay_result = sagepay_display(orders)
      end

      if orders.status == Order::STATUS_NEW
        check_box = "<input type='checkbox' name='check_pick_order' value=#{orders.id} class='check_pick_order'/>"
      else
        check_box = ""
      end

      data =[
          orders.id.to_s,
          "<span class='icon-down expand_row'></span>",
          check_box,
          h(orders.order_date.localtime),
          h(orders.channel_order_id),
          h(orders.full_name)
      ]

      if @enable_sagepay
        data += [sagepay_result[:cv2result],
                 sagepay_result[:address_result],
                 sagepay_result[:postcode_result],
                 sagepay_result[:threed_secure_status],
                 sagepay_result[:thirdman_action]]

      end

      if @can_change_status
        status = status_change_select(orders.status, orders.id)
      else
        status = orders.status_name
      end
      data += [status]
      data += ["<span class='icon icon-info-sign show-button' id='show_order_info_#{orders.id}'></span>#{orders.original_order_id.present? ? '<span style="font-size: x-large;">P</span>' : ''}",
               (orders.highlight_colour rescue ''),
               (orders.font_colour rescue '')
      ]
      data
    end
  end

  def items
    @items ||= fetch_items
  end

  def fetch_items
    items = Order.select("orders.id, channels.name as channel_name, orders.channel_order_id,orders.status, orders.original_order_id,
          orders.order_date, orders.customer_id,
          order_fraud_scores.cv2result, order_fraud_scores.address_result, order_fraud_scores.postcode_result, order_fraud_scores.threed_secure_status,
          order_fraud_scores.thirdman_action, order_fraud_scores.thirdman_score, cs.highlight_colour, cs.font_colour, customers.full_name").
        joins(:customer).
        joins(:channel).
        joins(:order_details).
        joins("inner join items on items.id = order_details.item_id").
        joins("left outer join order_fraud_scores on order_fraud_scores.order_id = orders.id").
        joins('left outer join channel_shipping_services cs on cs.id = orders.channel_shipping_service_id').
        order("#{sort_column} #{sort_direction}").
        where(:company_id => @company_id).
        group("orders.id")

    if params[:sSearch_2].present?
      case params[:sSearch_2]
        when 'PICKABLE'
          items = items.where("orders.status = '#{Order::STATUS_NEW}'")
        when 'INPROGRESS'
          items = items.where("orders.status = '#{Order::STATUS_WEIGHED}' OR orders.status = '#{Order::STATUS_PICKED}' OR orders.status = '#{Order::STATUS_AWAITING_TRACKING}' OR orders.status = '#{Order::STATUS_PICKING}'")
      end
    else
      if params[:sSearch_1].present?
        items = items.where("orders.status = :status", status: "#{params[:sSearch_1].to_s.gsub(' ', '_').gsub(':', '')}")
      end
    end


    if params[:sSearch].present?
      items = items.where("orders.id = :id_search or orders.channel_order_id like :search or customers.full_name like :search or items.sku like :search", search: "%#{params[:sSearch]}%", id_search: "#{params[:sSearch]}")
    end

    if @show.present? and (params[:sSearch].blank? and params[:sSearch_1].blank?)
      items = items.where("orders.status = ?", Order::STATUS_NEW)
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
    columns = %w[blank blank blank orders.order_date orders.channel_order_id customers.full_name blank blank blank blank blank status ]
    columns[params[:iSortCol_0].to_i]
  end

  def sort_direction
    params[:sSortDir_0] == "desc" ? "desc" : "asc"
  end

end

