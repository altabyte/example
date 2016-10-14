module NavigationHelpers
  def path_to(page_name)
    begin
      if page.has_content?("Server Error")
        puts "#{page.text.to_s.red}\n"
        assert(false, "Scenario failed due to an error reported\n")
      end
    rescue Selenium::WebDriver::Error::StaleElementReferenceError
      assert true
    end
    case page_name

      when /the sign in page/
        '/users/sign_in'
      when /the dashboard page/
        '/dashboard'
      when /the set location page/
        '/set_location'

      #nav bar selectors
      when /the orders page/
        '/orders'
      when /the fulfillment page/
        '/order_picks'
      when /the weighing page/
        '/order_weighing'
      when /the shipping page/
        '/order_shipments'
      when /the tracking page/
        '/dispatch_console'
      when /the customers page/
        '/customers'
      when /the items page/
        '/items'
      when /the reports page/
        '/reports'
      when /the companies page/
        '/companies'
      when /the shipping methods page/
        '/shipping_methods'
      when /the channel shipping services page/
        '/channel_shipping_services'
      when /the stock locations page/
        '/stock_locations'
      when /the channels page/
        '/channels'
      when /the channel statuses page/
        '/channel_statuses'
      when /the system settings page/
        '/system_settings'
      when /the users page/
        '/users'
      when /the company logs page/
        '/company_logs'
      when /the release notes page/
        '/release_notes'
      when /the fedex settings page/
        '/fedex_settings'
      when /the shipping matrices page/
        '/setup#shipping_matrices'
      when /the packaging types page/
        '/company_packaging_types'
      when /the shipping destinations page/
        '/shipping_destinations'
      when /the setup page/
        '/setup'
      else
        begin
          page_name =~ /the (.*) page/
          path_components = $1.split(/\s+/)
          self.send(path_components.push('path').join('_').to_s)
        rescue Object => e
          raise "Can't find mapping from \"#{page_name}\" to a path.\n" +
                    "Now, go and add a mapping in #{__FILE__}"
        end
    end
  end
end

World(NavigationHelpers)
