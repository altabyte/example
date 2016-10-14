module ApplicationHelper

  def maintenance_toolbar(&block)
    raw("<div class='maintenance_toolbar'>#{capture(&block)}</div>")
  end

  def maintenance_toolbar_save(disable=nil)
    disable = t('maintenance.save') unless disable.present?
    submit_tag t('maintenance.save'), {:class => 'btn btn-primary save-button', :disable_with => disable}
  end


  def maintenance_table_button_to_function(label, function, button_class='new-button', id=nil)
    content_tag 'td' do
      button_to_method(label, function, button_class, id)
    end
  end

  def button_to_method(name, function, button_class='new-button', id=nil)
    button_to_function(name, function, :class => button_class, :id => id)
  end


  def maintenance_table(id='maintenance_table', &block)
    raw("<table id='#{id}' class='table table-striped table-bordered'>#{capture(&block)}</table>")
  end

  def yn_select_collection
    [[t("general.negative"), "N"], [t("general.positive"), "Y"]]
  end

  def currency_collection
    [["United Arab Emirates Dirham", 'AED'],
     ["Afghanistan Afghani", 'AFN'],
     ["Albania Lek", 'ALL'],
     ["Armenia Dram", 'AMD'],
     ["Netherlands Antilles Guilder", 'ANG'],
     ["Angola Kwanza", 'AOA'],
     ["Argentina Peso", 'ARS'],
     ["Australia Dollar", 'AUD'],
     ["Aruba Guilder", 'AWG'],
     ["Azerbaijan New Manat", 'AZN'],
     ["Bosnia and Herzegovina Convertible Marka", 'BAM'],
     ["Barbados Dollar", 'BBD'],
     ["Bangladesh Taka", 'BDT'],
     ["Bulgaria Lev", 'BGN'],
     ["Bahrain Dinar", 'BHD'],
     ["Burundi Franc", 'BIF'],
     ["Bermuda Dollar", 'BMD'],
     ["Brunei Darussalam Dollar", 'BND'],
     ["Bolivia Boliviano", 'BOB'],
     ["Brazil Real", 'BRL'],
     ["Bahamas Dollar", 'BSD'],
     ["Bhutan Ngultrum", 'BTN'],
     ["Botswana Pula", 'BWP'],
     ["Belarus Ruble", 'BYR'],
     ["Belize Dollar", 'BZD'],
     ["Canada Dollar", 'CAD'],
     ["Congo/Kinshasa Franc", 'CDF'],
     ["Switzerland Franc", 'CHF'],
     ["Chile Peso", 'CLP'],
     ["China Yuan Renminbi", 'CNY'],
     ["Colombia Peso", 'COP'],
     ["Costa Rica Colon", 'CRC'],
     ["Cuba Convertible Peso", 'CUC'],
     ["Cuba Peso", 'CUP'],
     ["Cape Verde Escudo", 'CVE'],
     ["Czech Republic Koruna", 'CZK'],
     ["Djibouti Franc", 'DJF'],
     ["Denmark Krone", 'DKK'],
     ["Dominican Republic Peso", 'DOP'],
     ["Algeria Dinar", 'DZD'],
     ["Egypt Pound", 'EGP'],
     ["Eritrea Nakfa", 'ERN'],
     ["Ethiopia Birr", 'ETB'],
     ["Euro Member Countries", 'EUR'],
     ["Fiji Dollar", 'FJD'],
     ["Falkland Islands (Malvinas) Pound", 'FKP'],
     ["United Kingdom Pound", 'GBP'],
     ["Georgia Lari", 'GEL'],
     ["Guernsey Pound", 'GGP'],
     ["Ghana Cedi", 'GHS'],
     ["Gibraltar Pound", 'GIP'],
     ["Gambia Dalasi", 'GMD'],
     ["Guinea Franc", 'GNF'],
     ["Guatemala Quetzal", 'GTQ'],
     ["Guyana Dollar", 'GYD'],
     ["Hong Kong Dollar", 'HKD'],
     ["Honduras Lempira", 'HNL'],
     ["Croatia Kuna", 'HRK'],
     ["Haiti Gourde", 'HTG'],
     ["Hungary Forint", 'HUF'],
     ["Indonesia Rupiah", 'IDR'],
     ["Israel Shekel", 'ILS'],
     ["Isle of Man Pound", 'IMP'],
     ["India Rupee", 'INR'],
     ["Iraq Dinar", 'IQD'],
     ["Iran Rial", 'IRR'],
     ["Iceland Krona", 'ISK'],
     ["Jersey Pound", 'JEP'],
     ["Jamaica Dollar", 'JMD'],
     ["Jordan Dinar", 'JOD'],
     ["Japan Yen", 'JPY'],
     ["Kenya Shilling", 'KES'],
     ["Kyrgyzstan Som", 'KGS'],
     ["Cambodia Riel", 'KHR'],
     ["Comoros Franc", 'KMF'],
     ["Korea (North) Won", 'KPW'],
     ["Korea (South) Won", 'KRW'],
     ["Kuwait Dinar", 'KWD'],
     ["Cayman Islands Dollar", 'KYD'],
     ["Kazakhstan Tenge", 'KZT'],
     ["Laos Kip", 'LAK'],
     ["Lebanon Pound", 'LBP'],
     ["Sri Lanka Rupee", 'LKR'],
     ["Liberia Dollar", 'LRD'],
     ["Lesotho Loti", 'LSL'],
     ["Libya Dinar", 'LYD'],
     ["Morocco Dirham", 'MAD'],
     ["Moldova Leu", 'MDL'],
     ["Madagascar Ariary", 'MGA'],
     ["Macedonia Denar", 'MKD'],
     ["Myanmar (Burma) Kyat", 'MMK'],
     ["Mongolia Tughrik", 'MNT'],
     ["Macau Pataca", 'MOP'],
     ["Mauritania Ouguiya", 'MRO'],
     ["Mauritius Rupee", 'MUR'],
     ["Maldives (Maldive Islands) Rufiyaa", 'MVR'],
     ["Malawi Kwacha", 'MWK'],
     ["Mexico Peso", 'MXN'],
     ["Malaysia Ringgit", 'MYR'],
     ["Mozambique Metical", 'MZN'],
     ["Namibia Dollar", 'NAD'],
     ["Nigeria Naira", 'NGN'],
     ["Nicaragua Cordoba", 'NIO'],
     ["Norway Krone", 'NOK'],
     ["Nepal Rupee", 'NPR'],
     ["New Zealand Dollar", 'NZD'],
     ["Oman Rial", 'OMR'],
     ["Panama Balboa", 'PAB'],
     ["Peru Nuevo Sol", 'PEN'],
     ["Papua New Guinea Kina", 'PGK'],
     ["Philippines Peso", 'PHP'],
     ["Pakistan Rupee", 'PKR'],
     ["Poland Zloty", 'PLN'],
     ["Paraguay Guarani", 'PYG'],
     ["Qatar Riyal", 'QAR'],
     ["Romania New Leu", 'RON'],
     ["Serbia Dinar", 'RSD'],
     ["Russia Ruble", 'RUB'],
     ["Rwanda Franc", 'RWF'],
     ["Saudi Arabia Riyal", 'SAR'],
     ["Solomon Islands Dollar", 'SBD'],
     ["Seychelles Rupee", 'SCR'],
     ["Sudan Pound", 'SDG'],
     ["Sweden Krona", 'SEK'],
     ["Singapore Dollar", 'SGD'],
     ["Saint Helena Pound", 'SHP'],
     ["Sierra Leone Leone", 'SLL'],
     ["Somalia Shilling", 'SOS'],
     ["Seborga Luigino", 'SPL*'],
     ["Suriname Dollar", 'SRD'],
     ["Sao Tome and Principe Dobra", 'STD'],
     ["El Salvador Colon", 'SVC'],
     ["Syria Pound", 'SYP'],
     ["Swaziland Lilangeni", 'SZL'],
     ["Thailand Baht", 'THB'],
     ["Tajikistan Somoni", 'TJS'],
     ["Turkmenistan Manat", 'TMT'],
     ["Tunisia Dinar", 'TND'],
     ["Tonga Pa'anga", 'TOP'],
     ["Turkey Lira", 'TRY'],
     ["Trinidad and Tobago Dollar", 'TTD'],
     ["Tuvalu Dollar", 'TVD'],
     ["Taiwan New Dollar", 'TWD'],
     ["Tanzania Shilling", 'TZS'],
     ["Ukraine Hryvnia", 'UAH'],
     ["Uganda Shilling", 'UGX'],
     ["United States Dollar", 'USD'],
     ["Uruguay Peso", 'UYU'],
     ["Uzbekistan Som", 'UZS'],
     ["Venezuela Bolivar", 'VEF'],
     ["Viet Nam Dong", 'VND'],
     ["Vanuatu Vatu", 'VUV'],
     ["Samoa Tala", 'WST'],
     ["Communaute Financiere Africaine", 'XAF'],
     ["East Caribbean Dollar", 'XCD'],
     ["International Monetary Fund (IMF) Special Drawing Rights", 'XDR'],
     ["Communaute Financiere Africaine Franc", 'XOF'],
     ["Comptoirs Francais du Pacifique Franc", 'XPF'],
     ["Yemen Rial", 'YER'],
     ["South Africa Rand", 'ZAR'],
     ["Zambia Kwacha", 'ZMW'],
     ["Zimbabwe Dollar", 'ZWD'],
    ].sort()
  end

  def user_companies
    if User.current_user.company_id.present?
      Company.where(:id => User.current_user.company_id)
    else
      Company.all
    end
  end

  def company_users_for_stock_location(stock_location_id)
    if User.current_user.company_id.present?
      users = User.unscoped.where(:company_id => User.current_user.company_id)
    else
      users = User
    end
    users.where("id not in (select user_id from stock_location_users where stock_location_id = #{stock_location_id})")
  end

  def drop_down(name, id=nil)
    content_tag :li, :class => "dropdown" do
      drop_down_link(name, id) + drop_down_list { yield }
    end
  end

  def drop_down_link(name, id=nil)
    link_to(name_and_caret(name), "#", :class => "dropdown-toggle", "data-toggle" => "dropdown", :id => id)
  end


  def order_attribute_collection
    [[t("order_attributes.order_value"), "order_value"], [t("order_attributes.sku"), "sku"], [t("order_attributes.item_value"), "item_value"]]
  end


  def qualifier_select_collection
    [["="], [">="], ["<="]]
  end

  def datatable_icon(options)
    link_to('', "#", :class => options[:class], :id => options[:id])
  end

  def status_change_select(current_status, order_id)
    rules = []


    case current_status
      when 'NEW'
        rules << 'CANCELLED'
        rules << 'ON_HOLD'
        rules << 'REFUNDED'
      when 'PENDING'
        rules << 'CANCELLED'
        rules << 'ON_HOLD'
      when 'PICKING', 'PART_PICKED'
        rules << 'CANCELLED'
        rules << 'NEW'
      when 'PART PICKED'
        rules << 'CANCELLED'
        rules << 'NEW'
      when 'PICKED'
        rules << 'CANCELLED'
        rules << 'NEW'
      when 'PART_DISPATCHED'
      when 'DISPATCHED'
      when 'COMPLETE'
      when 'CANCELLED'
      when 'REFUNDED'
      when 'AWAITING_TRACKING'
        rules << 'CANCELLED'
      when 'AWAITING_INTEGRATION_INFO'
      when 'WEIGHED'
        rules << 'CANCELLED'
        rules << 'NEW'
      when 'DELIVERED'
      when 'ON HOLD'
        rules << 'CANCELLED'
        rules << 'NEW'
      when 'COMPLETE_WITH_ERROR'
      else
    end

    if rules and rules.count > 0
      html = "<select class='status_change_select' data-order_id='#{order_id}'>"
      html += "<option selected=selected value=#{current_status}>#{status_name_by_record(current_status)}</option>"
      rules.each do |rule|
        html += "<option value=#{rule}>#{status_name_by_record(rule)}</option>"
      end
      html += '<select>'
    else
      html = status_name_by_record(current_status)
    end
    html
  end

  def status_name(status)
    I18n.t("statuses.#{"Order::#{status}".constantize.to_s.downcase}")
  end

  def status_name_by_record(status)
    if status
      I18n.t("statuses.#{"Order::STATUS_#{status}".constantize.to_s.downcase}")
    else
      ''
    end
  end

  def status_select
    statuses = Order.get_statuses
    result = []
    statuses.each do |status|
      result << [I18n.t("statuses.#{"Order::#{status}".constantize.to_s.downcase}"), "#{"Order::#{status}".constantize.to_s}"]
    end
    result
  end

  def human_boolean(boolean)
    boolean==1 ? 'Yes' : 'No'
  end

  def download_overlap_select
    [5, 10, 30, 60]
  end

  def translate_status(status)
    I18n.t("statuses.#{status}")
  end

  def selectable_locations(company_id)
    Company.find(company_id).stock_locations.where('stock_only = 0 or stock_only IS NULL')
  end

end