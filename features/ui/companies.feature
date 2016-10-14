@javascript
@speed_fast
@ui

Feature: Manage Companies

  Scenario: Admin user should NOT be able to create a new company
    Given I am logged in as the ADMIN user
    Then I should be on the dashboard page

    When I follow "System"
    When I follow "Setup"
    Then I should be on the setup page


