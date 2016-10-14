module HtmlSelectorsHelpers
  def selector_for(locator)
    case locator

      #General selectors
      when /^the data table search field$/
        '.dataTables_filter input[type="text"]'
      when /system parameter filter/, /select filter/
        '#select_filter'
      when /^the remove line button$/
        '#btn_delete'
      when /^the navigation bar$/
        'div.top-menu'
      when /^the sub navigation bar$/
        'div.secondary-menu'
      when /^the submit button$/
        '.btn_submit'
      when /^the next button$/
        '.btn_next'
      when /^the previous button$/
        '.btn_previous'
      when /^the new button$/
        '.new-button'
      when /^the cancel button$/
        '.btn_cancel'
      when /^the apply button$/
        '.btn_apply'
      when /^the check button$/
        '.btn_check'
      when /a dialog title/
        ".ui-dialog-title"
      when /dialog content/
        ".ui-dialog-content"
      when /dialog buttonset/
        ".ui-dialog-buttonset"
      when /the close button/
        ".ui-dialog-titlebar-close"
      when /date picker button/
        ".ui-datepicker-trigger"
      when /the auto complete selection/
        ".ui-autocomplete"
      when /the new ([^"]*) button/
        "#new_#{$1.gsub(/\s/, '_')}"
      when /ibt edit pane/
        "#ibt_edit_pane"
      when /the new user button/
        "#new_user"
      when /user password confirmation field/
        "#user_password_confirmation"
      when /user password field/
        "#user_password"
      when /the basic details form/
        "#basic_details_form"
      when /the alertify ok button/
        '.alertify-ok'
      when /the alertify cancel button/
        '.alertify-cancel'

      when /the page/
        'html > body'
      when /the clear button/
        '#btn_clear'
      when /the (notice|error|info) flash/
        ".flash.#{$1}"
      when /an error message/
        ".notice"
      when /a link to reset my password/
        "#pwd_reset"
      when /the login button/
        "#btn_login_button"
      when /the continue button/
        "#btn_continue"
      when /the quick login workstation information/
        "div#workstation-info"
      when /the location select button/
        ".location_button"
      when /the back button/
        "#btn_back"
      when /the maintenance new button/
        ".new-button"
      when /the maintenance save button/, /the save button/
        ".save-button"
      when /the maintenance accept button/, /the send action button/, /the clear all button/
        ".accept-button"
      when /the maintenance create button/
        ".create"
      when /the maintenance edit button/, /the edit reward button/
        ".edit-button"
      when /the maintenance back button/
        ".back-button"
      when /the maintenance update button/
        ".update"
      when /the maintenance show button/
        ".show"
      when /the maintenance cancel button/
        "#cancel-link"
      when /the maintenance reopen button/
        "#reopen-link"
      when /any delete buttons/
        '#a[id^="delete_"]'
      when /the maintenance next button/
        ".next"
      when /the maintenance previous button/
        ".prev"
      when /the maintenance first button/
        ".first"
      when /the maintenance last button/
        ".last"

      #general maintenance screen selectors
      when /^the show button$/
        ".show-button"
      when /^the edit button$/
        ".edit-button"
      when /^the clone button$/
        ".clone-cell-button"
      when /^the delete button$/, /^the time and attendance approve button$/
        ".delete-button"
      when /the maintenance new cell button/
        ".new-button"
      when /no result message/, /the results? message/, /^a notification$/
        "#notice_notice"
      when /the footer/
        "#footer"

      #nav bar selectors
      when /the change location button/
        "#btn_change_location"
      when /the logout button/
        "#btn_logout"
      when /the home button/
        "#btn_home"
      when /the orders drop down button/
        "#btn_dd_orders"
      when /the orders button/
        "#btn_orders"
      when /the fulfillment button/
        "#btn_fulfillment"
      when /the weighing button/
        "#btn_weighing"
      when /the shipments button/
        "#btn_shipments"
      when /the tracking button/
        "#btn_tracking"
      when /the customers button/
        "#btn_customers"
      when /the items button/
        "#btn_items"
      when /the reports button/
        "#btn_reports"
      when /the support drop down button/
        "#btn_dd_support"
      when /the companies button/
        "#btn_companies"
      when /the setup drop down button/
        "#btn_dd_setup"
      when /the shipping methods button/
        "#btn_shipping_methods"
      when /the channel shipping services button/
        "#btn_channel_shipping_services"
      when /the stock locations button/
        "#btn_stock_locations"
      when /the channels button/
        "#btn_channels"
      when /the channel statuses button/
        "#btn_channel_statuses"
      when /the system settings button/
        "#btn_system_settings"
      when /the users button/
        "#btn_users"
      when /the logs button/
        "#btn_logs"
      when /the release notes button/
        "#btn_release_notes"

      when /new user popup/
        "#new_user_dialog"
      when /upload file button/
        "#upload_file"
      when /download file button/
        "#download_file"

      #setup selectors
      when /setup shipping matrices/
        "#btn_shipping_matrices"
      when /setup users/
        "#btn_users"
      when /the user basic details form/
        "#users_basic_details_form"
      when /the navigation menu/
        ".nav-collapse"

      when /"(.+)"/
        $1

      else
        raise "Can't find mapping from \"#{locator}\" to a selector.\n" +
                  "Now, go and add a mapping in #{__FILE__}"
    end
  end
end

World(HtmlSelectorsHelpers)
