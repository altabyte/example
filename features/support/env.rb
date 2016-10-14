require 'cucumber/rails'
require 'selenium-webdriver'

# Capybara defaults to CSS3 selectors rather than XPath.
# If you'd prefer to use XPath, just uncomment this line and adjust any
# selectors in your step definitions to use the XPath syntax.
# Capybara.default_selector = :xpath

# By default, any exception happening in your Rails application will bubble up
# to Cucumber so that your scenario will fail. This is a different from how 
# your application behaves in the production environment, where an error page will 
# be rendered instead.
#
# Sometimes we want to override this default behaviour and allow Rails to rescue
# exceptions and display an error page (just like when the app is running in production).
# Typical scenarios where you want to do this is when you test your error pages.
# There are two ways to allow Rails to rescue exceptions:
#
# 1) Tag your scenario (or feature) with @allow-rescue
#
# 2) Set the value below to true. Beware that doing this globally is not
# recommended as it will mask a lot of errors for you!
#
ActionController::Base.allow_rescue = false

# Remove/comment out the lines below if your app doesn't have a database.
# For some databases (like MongoDB and CouchDB) you may need to use :truncation instead.
begin
  DatabaseCleaner.strategy = :transaction
rescue NameError
  raise "You need to add database_cleaner to your Gemfile (in the :test group) if you wish to use it."
end

if ENV['HEADLESS'] == 'true'
  require 'headless'

  headless = Headless.new
  headless.start

  at_exit do
    headless.destroy
  end
end

if RbConfig::CONFIG['target_os'].include?("darwin")
  Selenium::WebDriver::Chrome.path = "/Applications/Google\ Chrome.app/Contents/MacOS/Google\ Chrome"
else
  Selenium::WebDriver::Chrome.path = "/usr/bin/chromium-browser"
end

Capybara.register_driver :selenium do |app|
  client = Selenium::WebDriver::Remote::Http::Default.new
  client.timeout = 120
  Capybara::Selenium::Driver.new(app, :browser => :chrome, :http_client => client)
  #Capybara::Selenium::Driver.new(app, :browser => :chrome)
end
Capybara.register_driver :selenium_firefox do |app|
  client = Selenium::WebDriver::Remote::Http::Default.new
  client.timeout = 120
  Capybara::Selenium::Driver.new(app, :browser => :firefox, :http_client => client)
end
Capybara.register_driver :rack_test do |app|
  Capybara::RackTest::Driver.new(app, :browser => :chrome)
end


Capybara.default_driver = :selenium

Capybara.default_wait_time = 2
Capybara.ignore_hidden_elements = true
Capybara.default_selector = :css
Cucumber::Rails::Database.javascript_strategy = :transaction
Cucumber::Rails::World.use_transactional_fixtures = false

