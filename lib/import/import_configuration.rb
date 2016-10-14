require 'rexml/document'

module ImportConfiguration
  def self.process_import_file(data)

    doc = REXML::Document.new(data)
    message = ''

    begin
      self.process_configuration(doc.elements['Configurations'])
    rescue => exc
      message = "Configuration Import Failed with error #{exc.to_s}"
      puts message
      Rollbar.error(exc)
    end

    if message.present?
      {:success => false, :message => message}
    end
    {:success => true}
  end

  def self.process_configuration(config_data)
    self.process_user(config_data.elements['SuperUser']) if config_data.elements['SuperUser'].present?

    config_data.elements.each('Companies/Company') do |company|
      self.process_company(company)
    end
  end


  def self.process_company(company_data)
    company = Company.find_or_initialize_by_name(company_data.elements['Name'].text)
    company.address_1 = company_data.elements['AddressLine1'].text rescue nil
    company.address_2 = company_data.elements['AddressLine2'].text rescue nil
    company.town = company_data.elements['Town'].text rescue nil
    company.county = company_data.elements['County'].text rescue nil
    company.post_code = company_data.elements['PostCode'].text rescue nil
    company.country = company_data.elements['Country'].text rescue nil
    company.client_share = company_data.elements['ClientShare'].text rescue nil
    company.telephone = company_data.elements['Telephone'].text rescue nil
    company.save

    company_data.elements.each('Users/User') do |user|
      self.process_user(user, company.id)
    end

    company_data.elements.each('StockLocations/StockLocation') do |stock_location|
      self.create_location(stock_location.elements['Name'].text, (stock_location.elements['Reference'].text rescue nil), company.id)
    end

    company_data.elements.each('Channels/Channel') do |channel|
      self.create_channel(channel, company.id)
    end

  end

  def self.create_channel(channel, company_id)
    new_channel = Channel.find_or_initialize_by_name_and_company_id(channel.elements['Name'].text, company_id)
    new_channel.connection_1 = channel.elements['Connection1'].text rescue nil
    new_channel.connection_2 = channel.elements['Connection2'].text rescue nil
    new_channel.connection_3 = channel.elements['Connection3'].text rescue nil
    new_channel.password_1 = channel.elements['Password1'].text rescue nil
    new_channel.password_2 = channel.elements['Password2'].text rescue nil
    new_channel.password_3 = channel.elements['Password3'].text rescue nil
    new_channel.system_channel_id = SystemChannel.find_by_name(channel.attributes['SystemChannelName'].to_s).id
    new_channel.use_company_address_flag = channel.elements['UseCompanyAddress'].text rescue 'Y'
    new_channel.product_master = channel.elements['ProductMaster'].text rescue 'N'
    new_channel.save!
    new_channel.channel_updated_now('ORDER', (DateTime.now() - 7.days))
    channel.elements.each('Statuses/Status') do |status|
      self.create_channel_status(new_channel.id, status)
    end

  end


  def self.process_user(user, company_id=nil)
    self.create_user(
        user.elements['Name'].text,
        user.elements['email_address'].text,
        user.elements['Password'].text,
        user.elements['Role'].text,
        (user.elements['HomePage'].text rescue nil),
        company_id
    )
  end

  def self.create_user(name, email, password, role_name, landing_page, company_id=nil)
    role = Role.find_by_name(role_name)
    user = User.find_or_create_by_email(email,
                                        :name => name,
                                        :password => password,
                                        :password_confirmation => password,
                                        :role_id => role.id,
                                        :default_landing_page => landing_page)

    if company_id.present?
      user.company_id = company_id
      user.save!
    end
  end

  def self.create_location(name, reference, company_id)

    stock_loc = StockLocation.find_or_create_by_company_id_and_name(company_id, name, :reference => reference)
    #create stock loc user record for all users
    User.where("company_id = #{company_id} or company_id IS NULL").all.each do |user|
      StockLocationUser.create(:user_id => user.id, :stock_location_id => stock_loc.id)
    end
  end

  def self.create_channel_status(channel_id, status_data)
    system_status="Order::STATUS_#{status_data.elements['SystemStatusName'].text.to_s.upcase}".constantize
    ChannelStatus.find_or_create_by_channel_id_and_status_name(
        channel_id,
        status_data.elements['Name'].text,
        :status => system_status,
        :is_outbound_status => (status_data.elements['IsOutBound'].text rescue 'N')
    )
  end

end