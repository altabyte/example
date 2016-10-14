@javascript
@speed_fast
@ui
@shipping

Feature: Manage Shipping Matrices UI

  Background:
    Given I change the setting "enable_shipping_matrix" for user "admin@ordermanager.biz" to "Y"
    Given I am logged in as the ADMIN user
    When I follow "System"
    When I follow "Setup"
    When I press setup shipping matrices
    Then  I should see the download file button
    And I press the upload file button

  Scenario: Check shipping matrix import - success
    When I attach the file "features/import_export/assets/shipping_matrices.csv" to "file"
    And I press the submit button
    And I should have 1 shipping_matrix records with the attribute "company_id" of "1"
    And there should be 1 visible rows in the table with id "shipping_matrices_table"

    And I see in grid the value "United Kingdom" on 1st row in column "1"
    And I see in grid the value "N" on 1st row in column "2"
    And I see in grid the value "0.0" on 1st row in column "3"
    And I see in grid the value "9999.9999" on 1st row in column "4"
    And I see in grid the value "0.0" on 1st row in column "5"
    And I see in grid the value "9999.99" on 1st row in column "6"
    And I see in grid the value "10.0" on 1st row in column "7"
    And I see in grid the value "Post Office" on 1st row in column "8"


  Scenario: Check shipping matrix import - first line failure - no country
    When I attach the file "features/import_export/assets/shipping_matrices_first_line_fail.csv" to "file"
    And I press the submit button
    And I should have 0 shipping_matrix records with the attribute "company_id" of "1"
    And there should be 0 visible rows in the table with id "shipping_matrices_table"
    And I should see "country cannot be blank"

  Scenario: Check shipping matrix import - second line failure - no weight_to
    When I attach the file "features/import_export/assets/shipping_matrices_second_line_failure.csv" to "file"
    And I press the submit button
    And I should have 0 shipping_matrix records with the attribute "company_id" of "1"
    And there should be 0 visible rows in the table with id "shipping_matrices_table"
    And I should see "Line2 weight_to cannot be blank"

  Scenario: Check shipping matrix import - second line failure - checked rollback
    When I attach the file "features/import_export/assets/shipping_matrices.csv" to "file"
    And I press the submit button
    And I should have 1 shipping_matrix records with the attribute "company_id" of "1"
    And there should be 1 visible rows in the table with id "shipping_matrices_table"

    And I press the upload file button

    When I attach the file "features/import_export/assets/shipping_matrices_second_line_failure.csv" to "file"
    And I press the submit button
    And I should have 1 shipping_matrix records with the attribute "company_id" of "1"
    And there should be 1 visible rows in the table with id "shipping_matrices_table"
    And I should see "weight_to cannot be blank"

    And I see in grid the value "United Kingdom" on 1st row in column "1"
    And I see in grid the value "N" on 1st row in column "2"
    And I see in grid the value "0.0" on 1st row in column "3"
    And I see in grid the value "9999.9999" on 1st row in column "4"
    And I see in grid the value "0.0" on 1st row in column "5"
    And I see in grid the value "9999.99" on 1st row in column "6"
    And I see in grid the value "10.0" on 1st row in column "7"
    And I see in grid the value "Post Office" on 1st row in column "8"


  Scenario: Check shipping matrix import - invalid weight_from
    When I attach the file "features/import_export/assets/shipping_matrices_invalid_weight_from.csv" to "file"
    And I press the submit button
    And I should have 0 shipping_matrix records with the attribute "company_id" of "1"
    And there should be 0 visible rows in the table with id "shipping_matrices_table"
    And I should see "weight_from cannot be converted to a number"


  Scenario: Check shipping matrix import - check each field - missing
    When I attach the file "features/import_export/assets/shipping_matrices_first_line_fail_all_missing.csv" to "file"
    And I press the submit button
    And I should have 0 shipping_matrix records with the attribute "company_id" of "1"
    And there should be 0 visible rows in the table with id "shipping_matrices_table"
    And I should see "shipping_service cannot be blank", "country cannot be blank", "order_subtotal_from cannot be blank", "order_subtotal_to cannot be blank", "weight_from cannot be blank", "weight_to cannot be blank", "shipping_cost cannot be blank"

  Scenario: Check shipping matrix import - check each field - numbers invalid
    When I attach the file "features/import_export/assets/shipping_matrices_number_invalid.csv" to "file"
    And I press the submit button
    And I should have 0 shipping_matrix records with the attribute "company_id" of "1"
    And there should be 0 visible rows in the table with id "shipping_matrices_table"
    And I should see "order_subtotal_from cannot be converted to a number", "order_subtotal_to cannot be converted to a number", "weight_from cannot be converted to a number", "weight_to cannot be converted to a number", "shipping_cost cannot be converted to a number"


  Scenario: Check shipping matrix import - country by name
    When I attach the file "features/import_export/assets/shipping_matrices_country_by_name.csv" to "file"
    And I press the submit button
    And I should have 2 shipping_matrix records with the attribute "company_id" of "1"
    And there should be 2 visible rows in the table with id "shipping_matrices_table"
    And I see in grid the value "United Kingdom" on 1st row in column "1"
    And I see in grid the value "United Kingdom" on 2nd row in column "1"

  Scenario: Check shipping matrix import - country by alpha3
    When I attach the file "features/import_export/assets/shipping_matrices_country_by_alpha3.csv" to "file"
    And I press the submit button
    And I should have 2 shipping_matrix records with the attribute "company_id" of "1"
    And there should be 2 visible rows in the table with id "shipping_matrices_table"
    And I see in grid the value "United Kingdom" on 1st row in column "1"
    And I see in grid the value "Thailand" on 2nd row in column "1"

  Scenario: Check shipping matrix import - country by invalid
    When I attach the file "features/import_export/assets/shipping_matrices_country_invalid.csv" to "file"
    And I press the submit button
    And I should have 0 shipping_matrix records with the attribute "company_id" of "1"
    And there should be 0 visible rows in the table with id "shipping_matrices_table"
    And I should see "country cannot be found"

  Scenario: Check shipping matrix import - shipping service invalid
    When I attach the file "features/import_export/assets/shipping_matrices_shipping_service_invalid.csv" to "file"
    And I press the submit button
    And I should have 0 shipping_matrix records with the attribute "company_id" of "1"
    And there should be 0 visible rows in the table with id "shipping_matrices_table"
    And I should see "shipping_service cannot be found"














