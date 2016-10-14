@javascript
@speed_fast
@ui
@users

Feature: Users

  Scenario: Super and admin datatable check
    Given I am logged in as the ADMIN user
    Then I should be on the dashboard page

    When I follow "System"
    When I follow "Setup"
    Then I press setup users

    Then I should see "Showing 1 to 2 of 2 entries"
    And there should be 2 visible rows in the table with id "users"

  Scenario: Add user as super user success
    Given I am logged in as the SUPER user
    When I follow "System"
    When I follow "Setup"
    Then I press setup users

    And I press the maintenance new button
    And wait 10 seconds for the new user popup to appear

    When I fill in "Name" with "User 3"
    And I fill in "email" with "user3@ordermanager.biz"
    And I fill in the user password field with "Please1"
    And I fill in the user password confirmation field with "Please1"

    And I press the maintenance save button

    Then I should see "Showing 1 to 4 of 4 entries"
    And there should be 4 visible rows in the table with id "users"
    And I should have 3 user records with the attribute "company_id" of "1"

  Scenario: Add user as super user passwords dont match
    Given I am logged in as the SUPER user
    When I follow "System"
    When I follow "Setup"
    Then I press setup users

    And I press the maintenance new button
    And wait 10 seconds for the new user popup to appear

    When I fill in "Name" with "User 3"
    And I fill in "email" with "user3@ordermanager.biz"
    And I fill in the user password field with "Please1"
    And I fill in the user password confirmation field with "Please2"

    And I press the maintenance save button

    Then I should see "doesn't match confirmation"

    Then I press the close button

    Then I should see "Showing 1 to 3 of 3 entries"
    And there should be 3 visible rows in the table with id "users"
    And I should have 2 user records with the attribute "company_id" of "1"

  Scenario: Add user as super user name missing
    Given I am logged in as the SUPER user
    When I follow "System"
    When I follow "Setup"
    Then I press setup users

    And I press the maintenance new button
    And wait 10 seconds for the new user popup to appear

    And I fill in "email" with "user3@ordermanager.biz"
    And I fill in the user password field with "Please1"
    And I fill in the user password confirmation field with "Please1"

    And I press the maintenance save button

    Then I should see "can't be blank"

    Then I press the close button

    Then I should see "Showing 1 to 3 of 3 entries"
    And there should be 3 visible rows in the table with id "users"
    And I should have 2 user records with the attribute "company_id" of "1"

  Scenario: Add user as super user email missing
    Given I am logged in as the SUPER user
    When I follow "System"
    When I follow "Setup"
    Then I press setup users

    And I press the maintenance new button
    And wait 10 seconds for the new user popup to appear

    When I fill in "Name" with "User 3"
    And I fill in the user password field with "Please1"
    And I fill in the user password confirmation field with "Please1"

    And I press the maintenance save button

    Then I should see "can't be blank"

    Then I press the close button

    Then I should see "Showing 1 to 3 of 3 entries"
    And there should be 3 visible rows in the table with id "users"
    And I should have 2 user records with the attribute "company_id" of "1"

  Scenario: Add user as super user password missing
    Given I am logged in as the SUPER user
    When I follow "System"
    When I follow "Setup"
    Then I press setup users

    And I press the maintenance new button
    And wait 10 seconds for the new user popup to appear

    When I fill in "Name" with "User 3"
    And I fill in "email" with "user3@ordermanager.biz"

    And I press the maintenance save button

    Then I should see "can't be blank"

    Then I press the close button

    Then I should see "Showing 1 to 3 of 3 entries"
    And there should be 3 visible rows in the table with id "users"
    And I should have 2 user records with the attribute "company_id" of "1"

  Scenario: Add user as super user password too short
    Given I am logged in as the SUPER user
    When I follow "System"
    When I follow "Setup"
    Then I press setup users

    And I press the maintenance new button
    And wait 10 seconds for the new user popup to appear

    When I fill in "Name" with "User 3"
    And I fill in "email" with "user3@ordermanager.biz"
    And I fill in the user password field with "Pl1"
    And I fill in the user password confirmation field with "Pl1"

    And I press the maintenance save button

    Then I should see "is too short"

    Then I press the close button

    Then I should see "Showing 1 to 3 of 3 entries"
    And there should be 3 visible rows in the table with id "users"
    And I should have 2 user records with the attribute "company_id" of "1"


  Scenario: Add user as admin user
    Given I am logged in as the ADMIN user
    When I follow "System"
    When I follow "Setup"
    Then I press setup users

    And I press the maintenance new button
    And wait 10 seconds for the new user popup to appear

    Then I should not see "Company" within the new user popup

    When I fill in "Name" with "User 3"
    And I fill in "email" with "user3@ordermanager.biz"
    And I fill in the user password field with "Please1"
    And I fill in the user password confirmation field with "Please1"

    And I press the maintenance save button

    Then I should see "Showing 1 to 3 of 3 entries"
    And there should be 3 visible rows in the table with id "users"
    And I should have 3 user records with the attribute "company_id" of "1"

  Scenario: Edit existing user as admin user password too short
    Given I am logged in as the ADMIN user
    When I follow "System"
    When I follow "Setup"
    Then I press setup users

    And   click edit for the user with name "Admin User"
    And wait 10 seconds for the user basic details form to appear

    And I fill in the user password field with "pl"
    And I fill in the user password confirmation field with "pl"

    And I press the maintenance save button
    Then I should see "is too short"

    Then I press the back button

    And   click edit for the user with name "Admin User"
    And wait 10 seconds for the user basic details form to appear

    And I fill in the user password field with "Please5"
    And I fill in the user password confirmation field with "Please5"

    And I press the maintenance save button
    Then I press the back button

    Then I should see "Showing 1 to 2 of 2 entries"
    And there should be 2 visible rows in the table with id "users"
    And I should have 2 user records with the attribute "company_id" of "1"

  Scenario: Super and admin datatable filter check
    Given I am logged in as the SUPER user
    Then I should be on the orders page

    When I follow "System"
    When I follow "Setup"
    Then I press setup users

    Then I should see "Showing 1 to 3 of 3 entries"
    And there should be 3 visible rows in the table with id "users"

    And   I select "Admin" from select filter
    Then I should see "Showing 1 to 1 of 1 entries"
    And there should be 1 visible rows in the table with id "users"
    And   I select "SuperUser" from select filter
    Then I should see "Showing 1 to 1 of 1 entries"
    And there should be 1 visible rows in the table with id "users"

    Then I press the logout button

    Given I am logged in as the ADMIN user
    Then I should be on the dashboard page

    When I follow "System"
    When I follow "Setup"
    Then I press setup users

    Then I should see "Showing 1 to 2 of 2 entries"
    And there should be 2 visible rows in the table with id "users"
    And   I select "Admin" from select filter
    Then I should see "Showing 1 to 1 of 1 entries"
    And there should be 1 visible rows in the table with id "users"

  Scenario: Add user to company two via super user
    Given I am logged in as the SUPER user
    When I follow "Change Location"
    And I click the 3rd instance of the location select button
    When I follow "System"
    When I follow "Setup"
    Then I press setup users

    And I press the maintenance new button
    And wait 10 seconds for the new user popup to appear

    When I fill in "Name" with "User 3"
    And I fill in "email" with "user3@ordermanager.biz"
    And I fill in the user password field with "Please1"
    And I fill in the user password confirmation field with "Please1"

    And I press the maintenance save button

    Then I should see "Showing 1 to 4 of 4 entries"
    And there should be 4 visible rows in the table with id "users"
    And I should have 3 user records with the attribute "company" of "Test Company 2"
    And I should have 2 user records with the attribute "company_id" of "1"


  Scenario: Add user to company two via super user check cross company
    Then I should have 4 stock location records
    Given I am logged in as the SUPER user
    When I follow "Change Location"
    And I click the 3rd instance of the location select button
    When I follow "System"
    When I follow "Setup"
    Then I press setup users

    And I press the maintenance new button
    And wait 10 seconds for the new user popup to appear

    When I fill in "Name" with "User 3"
    And I fill in "email" with "user3@ordermanager.biz"
    And I fill in the user password field with "Please1"
    And I fill in the user password confirmation field with "Please1"
    When I select "Admin" from "user_role_id"

    And I press the maintenance save button

    Then I should see "Showing 1 to 4 of 4 entries"
    And there should be 4 visible rows in the table with id "users"
    And I should have 3 user records with the attribute "company" of "Test Company 2"
    And I should have 2 user records with the attribute "company" of "Test Company 1"

    Then I press the logout button
    Given I am logged in as the USER3 user
    When I follow "System"
    When I follow "Setup"
    Then I press setup users
    Then I should see "Showing 1 to 3 of 3 entries"
    And there should be 3 visible rows in the table with id "users"

    And I press the maintenance new button
    And wait 10 seconds for the new user popup to appear

    Then I should not see "Company" within the new user popup

  Scenario: Check accessible roles on user creation
    Given I am logged in as the SUPER user
    When I follow "System"
    When I follow "Setup"
    Then I press setup users

    And I press the maintenance new button
    And wait 10 seconds for the new user popup to appear


    And the dropdown "user_role_id" should contain exactly the options SuperUser, Admin, User

    Then I press the close button

    Then I press the logout button
    Given I am logged in as the ADMIN user
    When I follow "System"
    When I follow "Setup"
    When I follow "Users"

    And I press the maintenance new button
    And wait 10 seconds for the new user popup to appear

    Then I should not see "Company" within the new user popup
    And the dropdown "user_role_id" should contain exactly the options Admin, User

  Scenario: Check user creation with admin role
    Given I am logged in as the SUPER user
    When I follow "System"
    When I follow "Setup"
    Then I press setup users

    And I press the maintenance new button
    And wait 10 seconds for the new user popup to appear


    And the dropdown "user_role_id" should contain exactly the options SuperUser, Admin, User
    When I select "Admin" from "user_role_id"

    When I fill in "Name" with "User 3"
    And I fill in "email" with "user3@ordermanager.biz"
    And I fill in the user password field with "Please1"
    And I fill in the user password confirmation field with "Please1"

    And I press the maintenance save button
    Then I should see "Showing 1 to 4 of 4 entries"
    And there should be 4 visible rows in the table with id "users"
    And I should have 3 user records with the attribute "company" of "Test Company 1"

    And I should have 3 users with user role "Admin"
#
  Scenario: Check accessible roles on user edit
    Given I am logged in as the ADMIN user
    When I follow "System"
    When I follow "Setup"
    Then I press setup users

    And   click edit for the user with name "Admin User"
    And wait 10 seconds for the user basic details form to appear
    And the dropdown "user_role_id" should contain exactly the options Admin, User

    Then I press the logout button
    Given I am logged in as the SUPER user
    When I follow "System"
    When I follow "Setup"

    Then I press setup users

    And   I select "SuperUser" from select filter
    And   click edit for the user with name "Super User"
    And wait 10 seconds for the user basic details form to appear
    And the dropdown "user_role_id" should contain exactly the options SuperUser, Admin, User

  Scenario: Add user to company two via super user and delete
    Given I am logged in as the SUPER user
    When I follow "Change Location"
    And I click the 3rd instance of the location select button
    When I follow "System"
    When I follow "Setup"
    Then I press setup users

    And I press the maintenance new button
    And wait 10 seconds for the new user popup to appear

    When I fill in "Name" with "User 3"
    And I fill in "email" with "user3@ordermanager.biz"
    And I fill in the user password field with "Please1"
    And I fill in the user password confirmation field with "Please1"

    And I press the maintenance save button

    Then I should see "Showing 1 to 4 of 4 entries"
    And there should be 4 visible rows in the table with id "users"
    And I should have 3 user records with the attribute "company" of "Test Company 2"
    Then  I should see "User 3"

    And   click delete for the user with name "User 3"
    And   wait 2 seconds
    And   I press the alertify ok button
    And   wait 2 seconds
    Then  I should not see "User 3"

  Scenario: Check user edit change role
    Given I am logged in as the SUPER user
    When I follow "System"
    When I follow "Setup"
    Then I press setup users

    And   click edit for the user with name "Admin User"
    And wait 10 seconds for the user basic details form to appear
    When I select "SuperUser" from "user_role_id"
    And I press the maintenance save button
    Then I wait 5 seconds
    And I should have 2 users with user role "SuperUser"








