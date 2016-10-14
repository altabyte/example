@javascript
@speed_fast
@ui

Feature: Manage Log On

  Scenario: Simple Log On and log out - admin@ordermanager
    Given I am on the sign in page

    When I fill in "Email" with "admin@ordermanager.biz"
    And I fill in "Password" with "Please1"
    And I press the login button
    And click the 1st instance of the location select button
    Then I should be on the dashboard page

    When I press the logout button
    Then I should be on the sign in page


  Scenario Outline: User Log On - Incorrect Details
    Given I am on the sign in page

    When I fill in "Email" with "<uname>"
    And fill in "Password" with "<pword>"
    And press the login button
    Then I should be on the sign in page"
    And should see "Invalid email or password"

  Examples:
    | uname                  | pword         |
    | 123@123.com            | Please1       |
    | admin@ordermanager.biz | WRONGPASSWORD |
    | admin@ordermanager.biz |               |
    |                        | WRONGPASSWORD |


  Scenario: Login as admin@ordermanager with stock location id set
    Given I visit the path "/users/sign_in?location_name=LOCATION1&company_name=Test%20Company%201"
    When I fill in "Email" with "admin@ordermanager.biz"
    And I fill in "Password" with "Please1"
    And I press the login button
    Then I should be on the dashboard page

  Scenario: Change location button
    Given I am on the sign in page

    When I fill in "Email" with "admin@ordermanager.biz"
    And I fill in "Password" with "Please1"
    And I press the login button
    And click the 1st instance of the location select button
    Then I should be on the dashboard page

    And I press the change location button
    Then I should be on the the set location page

    And click the 2nd instance of the location select button
    Then I should see "LOCATION2" within the footer

  Scenario: Login as admin@ordermanager using auth token with valid location
    Given I visit the login screen with auth token for "admin@ordermanager.biz" and location "LOCATION1"
    Then I should be on the dashboard page

  Scenario: Login as admin@ordermanager using auth token with invalid location
    Given I visit the login screen with auth token for "admin@ordermanager.biz" and location "ARDS"
    Then I should be on the the set location page

  Scenario: Login as invalid user with valid location and company
    Given I visit the path "/users/sign_in?email='123@123.com&user_token=12341234&location_name=LOCATION1&company_name=Test%20Company%201"
    When I fill in "Email" with "admin@ordermanager.biz"
    And I fill in "Password" with "Please1"
    And I press the login button
    Then I should be on the dashboard page

  Scenario: Login as invalid user with valid location and no company
    Given I visit the path "/users/sign_in?email='123@123.com&user_token=12341234&location_name=LOCATION1"
    Then I should be on the sign in page
    When I fill in "Email" with "admin@ordermanager.biz"
    And I fill in "Password" with "Please1"
    And I press the login button
    Then I should be on the the set location page
