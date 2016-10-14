@javascript
@speed_fast
@ui
@navigation

Feature: Navigation

  Scenario: Home button as admin user

    Given I am on the sign in page
    When I fill in "Email" with "admin@ordermanager.biz"
    And I fill in "Password" with "Please1"
    And I press the login button
    And click the 1st instance of the location select button
    Then I should be on the dashboard page
    And I press the customers button
    Then I should be on the customers page
    And I press the home button
    Then I should be on the dashboard page
    Then I press the logout button
    And I should be on the sign in page


  Scenario Outline: Change user home page and validate home link

    Given I set default_landing_page to "<landing_page>" for the User record where "email = 'admin@ordermanager.biz'"
    Given I am on the sign in page
    When I fill in "Email" with "admin@ordermanager.biz"
    And I fill in "Password" with "Please1"
    And I press the login button
    And click the 1st instance of the location select button
    Then I should be on <page>
    And I press the customers button
    Then I should be on the customers page
    And I press the home button
    Then I should be on <page>
    Then I press the logout button
    And I should be on the sign in page

  Examples:
    | landing_page    | page                     |
    | orders          | the orders page          |
    | order_shipments | the order shipments page |
    | order_picks     | the fulfillment page     |

  Scenario: Change user home page during test

    Given I am on the sign in page
    When I fill in "Email" with "admin@ordermanager.biz"
    And I fill in "Password" with "Please1"
    And I press the login button
    And click the 1st instance of the location select button
    Then I should be on the dashboard page
    And I press the customers button
    Then I should be on the customers page
    Then I set default_landing_page to "order_shipments" for the User record where "email = 'admin@ordermanager.biz'"
    And I press the home button
    Then I should be on the order shipments page
    Then I press the logout button
    And I should be on the sign in page

  Scenario: Check all navigation links
    Given I change the setting "enable_shipping_matrix" for user "super@ordermanager.biz" to "Y"
    Given I set default_landing_page to "" for the User record where "email = 'super@ordermanager.biz'"
    Given I am on the sign in page
    When I fill in "Email" with "super@ordermanager.biz"
    And I fill in "Password" with "PleasePlease1"
    And I press the login button
    And click the 1st instance of the location select button
    Then I should be on the dashboard page

    When I follow "Orders"
    When I follow "1 > Orders"
    Then I should be on the orders page

    When I follow "Orders"
    When I follow "2 > Fulfillment"
    Then I should be on the fulfillment page

    When I follow "Orders"
    When I follow "3 > Weigh Order"
    Then I should be on the weighing page

    When I follow "Orders"
    When I follow "4 > Ship Orders"
    Then I should be on the shipping page

    When I follow "Orders"
    When I follow "5 > Tracking Console"
    Then I should be on the tracking page

    And I press the customers button
    Then I should be on the customers page

    And I press the reports button
    Then I should be on the reports page

    When I follow "System"
    When I follow "Setup"
    Then I should be on the setup page






