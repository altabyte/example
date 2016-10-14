When /^(?:|I )visit the login screen with auth token for "([^"]*)" and location "([^"]*)"/ do |user, location|

  user = User.find_by_email(user) rescue nil
  if user.present?
    visit ("/users/sign_in?email=#{user.email}&user_token=#{user.authentication_token}&location_name=#{location}")
  else
    message = "User not found!"
    assert(false, message)
  end
end

Given /^get user ([^"]*) and fill$/ do |account|
  sleep 1
  password="", user=""
  case account
    when "super"
      user = User.find_by_email('super@ordermanager.biz')
      password = "PleasePlease1"
    when "admin"
      user = User.find_by_email('admin@ordermanager.biz')
      password = "Please1"
    when "user2"
      user = User.find_by_email('user2@ordermanager.biz')
      password = "Please1"
    when "user"
      user = User.find_by_email('user@ordermanager.biz')
      password = "Please1"
    when "user3"
      user = User.find_by_email('user3@ordermanager.biz')
      password = "Please1"
    when "admin2"
      user = User.find_by_email('admin2@ordermanager.biz')
      password = "Please1"
    else
      assert(false, "Not a standard operator '#{account}', try step 'I am logged in as the \" \" user with password \" \"'")
  end
  step "I fill in \"Email\" with \"#{user.email}\""
  step "I fill in \"Password\" with \"#{password}\""
  step "I press the login button"
end

Given /^(?:|I )am logged in as the ([^"]*) [Uu]ser$/ do |account|
  account.to_s.downcase!
  step "I am on the sign in page"
  #find the user
  step "get user #{account} and fill"

  case account
    when "super"
      user = User.find_by_email('super@ordermanager.biz')
    when "admin"
      user = User.find_by_email('admin@ordermanager.biz')
    when "user"
      user = User.find_by_email('user@ordermanager.biz')
    when "admin2"
      user = User.find_by_email('admin2@ordermanager.biz')
    when "user2"
      user = User.find_by_email('user2@ordermanager.biz')
    when "user3"
      user = User.find_by_email('user3@ordermanager.biz')
    else
      assert(false, "Not a standard operator '#{account}', try step 'I am logged in as the \" \" user with password \" \"'")
  end

  if user.stock_locations.count > 1
    step "click the 1st instance of the location select button"
  end
end

Given /(?:|I )have a company "([^"]*)"$/ do |name|
  Company.create(:name => name)
end

Given /(?:|I )have a company "([^"]*)" with "([^"]*)"$/ do |name, user|
  company = Company.create(:name => name)

  stock_location = StockLocation.create(:name => 'LOCATION_1', :company_id => company.id, :reference => company.id)

  case user
    when 'USER2'
      user = User.new
      user.company_id = company.id
      user.name = "User 2"
      user.email = "user2@ordermanager.biz"
      user.password = "Please1"
      user.password_confirmation = "Please1"
      user.default_landing_page = "orders"
      user.save!

      StockLocationUser.create(:user_id => user.id, :stock_location_id => stock_location.id)
  end
end
