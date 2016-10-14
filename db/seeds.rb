#!/bin/env ruby
# encoding: utf-8

def initiate_seed
#truncate first ---- not while deving
  conn = ActiveRecord::Base.connection
  tables = conn.execute("show tables").map { |r| r[0] }
  tables.delete "schema_migrations"
  tables.each { |t| conn.execute("TRUNCATE #{t}") }

  puts 'Creating Default Roles'
  Role.create(:name => 'SuperUser')
  Role.create(:name => 'Admin')
  Role.create(:name => 'User')

  puts 'Creating System Channels'
  create_system_channels('MAGENTO', 'HOST', 'USERNAME', 'STORE VIEW CODE', 'Y', 'Y', 'Y', 'API KEY', '', '', 'Y', 'N', 'N', 'Y', 'WEBSITE CODE')
  create_system_channels('AMAZON', 'SELLER ID', 'MERCHANT ID', 'MARKETPLACE', 'Y', 'Y', 'Y', 'AWS KEY', 'AWS SECRET', '', 'Y', 'Y', 'N', 'N', '')
  create_system_channels('EBAY', 'USER TOKEN', '', '', 'Y', 'N', 'N', '', '', '', 'N', 'N', 'N', 'N', '')

  puts 'Creating Shipping Services'
  create_shipping_services

  puts 'Create System Settings'
  create_system_settings

end

def create_system_settings
  SystemSetting.update_settings
end

def create_system_channels(channel, con_1_text, con_2_text, con_3_text, con_1_enabled, con_2_enabled,
                           con_3_enabled, pass_1_text, pass_2_text, pass_3_text, pass_1_enabled, pass_2_enabled, pass_3_enabled, con_4_enabled, con_4_text)

  system_channel = SystemChannel.create(:name => channel)

  SystemChannelSetting.create(
      :system_channel_id => system_channel.id,
      :setting_1_text => con_1_text,
      :setting_2_text => con_2_text,
      :setting_3_text => con_3_text,
      :setting_1_enabled => con_1_enabled,
      :setting_2_enabled => con_2_enabled,
      :setting_3_enabled => con_3_enabled,
      :password_1_text => pass_1_text,
      :password_2_text => pass_2_text,
      :password_3_text => pass_3_text,
      :password_1_enabled => pass_1_enabled,
      :password_2_enabled => pass_2_enabled,
      :password_3_enabled => pass_3_enabled,
      :setting_4_text => con_4_enabled,
      :setting_4_enabled => con_4_text

  )
end

def create_user(name, email, password, role, landing_page, company_id=nil)
  user = User.create(
      :name => name,
      :email => email,
      :password => password,
      :password_confirmation => password,
      :default_landing_page => landing_page)

  if company_id.present?
    user.company_id = company_id
    user.save
  end

  RolesUsers.create(:role_id => role.id, :user_id => user.id)
end

def create_locations(locations)
  locations.each { |type|
    stock_loc = StockLocation.create(:name => type)
    #create stock loc user record for all users
    User.all.each do |user|
      StockLocationUser.create(:user_id => user.id, :stock_location_id => stock_loc.id)
    end
  }
end

def create_location(location)
  stock_loc = StockLocation.create(:name => location[0], :reference => location[1], :company_id => Company.first.id)
  #create stock loc user record for all users
  User.all.each do |user|
    StockLocationUser.create(:user_id => user.id, :stock_location_id => stock_loc.id)
  end
end

def create_shipping_services()

  shipping_method = ShippingMethod.create(:name => "Royal Mail", :system_method => "Y", :tracking_information => 'tracker2', :code => 'RM', :default_weight => '1.0', :aftership_code => 'royal-mail')

  #manual shipping service for royal mail
  shipping_method = ShippingMethod.create(:name => "Royal Mail - Post Office", :system_method => "Y", :tracking_information => 'tracker2', :code => 'RMPO', :aftership_code => 'royal-mail')
  ShippingService.create(:name => 'Post Office', :tracked => 1, :shipping_method_id => shipping_method.id)

  shipping_method = ShippingMethod.create(:name => "FEDEX", :system_method => "Y", :code => 'FDX', :aftership_code => 'fedex')
  Fedex::Request::Base::SERVICE_TYPES.each do |service|
    ShippingService.create(:name => service, :tracked => 0, :shipping_method_id => shipping_method.id, :tracked => 1)
  end


  shipping_method = ShippingMethod.create(:name => "DPD", :system_method => "Y", :tracking_information => 'tracker1', :tracking_url => 'http://www2.dpd.ie/Services/QuickTrack/tabid/222/ConsignmentID/#TRACKING_NUMBER#/Default.aspx', :code => 'DPD-IE', :aftership_code => 'dpd-ireland')
  ShippingService.create(:name => 'DPD - A', :shipping_method_id => shipping_method.id, :tracked => 1, :account_number => '3796L9', :integration_identifier => "DPD")
  ShippingService.create(:name => 'DPD - B', :shipping_method_id => shipping_method.id, :tracked => 1, :account_number => '4141L9', :integration_identifier => "DPD")

  shipping_method = ShippingMethod.create(:name => "OTHER", :system_method => "Y", :code => 'OTH')
  ShippingService.create(:name => 'OTHER', :tracked => 0, :shipping_method_id => shipping_method.id)


end


initiate_seed