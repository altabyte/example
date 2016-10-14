class ExchangeRatesDatatable

  delegate :params, :h, :link_to, :link_to_function, :image_tag, :datatable_icon, :currency_collection, :t, to: :@view

  def initialize(view, company_id)
    @company_id = company_id
    @view = view
  end

  def as_json(options = {})
    if @company_id.present?
      total_count = ExchangeRate.where(:company_id => @company_id).count
    else
      total_count = ExchangeRate.count
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
      toCurrency = (currency_collection.find { |h| h[1] == item.to_currency }[0] rescue item.to_currency)
      [
          toCurrency,
          h(item.exchange_rate),
          datatable_icon({:class => 'edit-button', :id => "edit_exchange_rate_#{item.id}"}),
      ]

    end
  end

  def items
    @items ||= fetch_items
  end

  def fetch_items
    items = ExchangeRate.order("#{sort_column} #{sort_direction}")

    if @company_id.present?
      items = items.where(:company_id => @company_id)
    end

    if params[:sSearch].present?
      items = items.where("to_currency like :search", search: "%#{params[:sSearch]}%")
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
    columns = %w[to_currency exchange_rate]
    columns[params[:iSortCol_0].to_i]
  end

  def sort_direction
    params[:sSortDir_0] == "desc" ? "desc" : "asc"
  end

end
