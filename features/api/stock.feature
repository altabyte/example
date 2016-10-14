@api

Feature: API Import Stock
  Import data via API Endpoints

  Background:
    Given I send and accept XML
    Given I use the authentication token for "admin@ordermanager.biz"
    When I send a POST request to "/api/v1/import/submit.xml?import_type=ITEM" with the following:
    """
      <Items>
          <Item>
              <SKU>959596794</SKU>
              <ItemName>Test Item 1</ItemName>
              <Description>Test Item 1 Description</Description>
              <Colour>Red</Colour>
              <Size>XXL</Size>
              <HarmonizationCode>9797744</HarmonizationCode>
              <CountryCode>US</CountryCode>
              <ItemWeight>1.5</ItemWeight>
          </Item>
          <Item>
              <SKU>959596791</SKU>
              <ItemName>Test Item 2</ItemName>
              <Description>Test Item 2 Description</Description>
              <Colour>Red</Colour>
              <Size>XXL</Size>
              <HarmonizationCode>9797711</HarmonizationCode>
              <CountryCode>US</CountryCode>
              <ItemWeight>1.5</ItemWeight>
          </Item>
          <Item>
              <SKU>95959671</SKU>
              <ItemName>Test Item 2</ItemName>
          </Item>
      </Items>
    """

  Scenario: Import stock for three items
    When I send a POST request to "/api/v1/import/submit.xml?import_type=STOCK" with the following:
    """
      <Items>
          <ItemStock SKU='959596794' Type='TOTAL'>
            <Qty>100</Qty>
          </ItemStock>
          <ItemStock SKU='959596791' Type='TOTAL'>
            <Qty>120</Qty>
          </ItemStock>
          <ItemStock SKU='95959671' Type='TOTAL'>
            <Qty>130</Qty>
          </ItemStock>
      </Items>
    """
    Then the result should have a "success" of "3"
    Then the response status should be "200"
    And I should have 1 item records with the attribute "group_stock" of "100"
    And I should have 1 item records with the attribute "group_stock" of "120"
    And I should have 1 item records with the attribute "group_stock" of "130"

  Scenario: Import stock for three items - one invalid sku
    When I send a POST request to "/api/v1/import/submit.xml?import_type=STOCK" with the following:
    """
      <Items>
          <ItemStock SKU='123ABC123' Type='TOTAL'>
            <Qty>100</Qty>
          </ItemStock>
          <ItemStock SKU='959596791' Type='TOTAL'>
            <Qty>120</Qty>
          </ItemStock>
          <ItemStock SKU='95959671' Type='TOTAL'>
            <Qty>130</Qty>
          </ItemStock>
      </Items>
    """
    Then the result should have a "success" of "2"
    Then the result should have a "failed" of "1"
    Then the response status should be "200"
    And I should have 0 item records with the attribute "group_stock" of "100"
    And I should have 1 item records with the attribute "group_stock" of "120"
    And I should have 1 item records with the attribute "group_stock" of "130"


  Scenario: Import stock for three items totals then add and deduct
    When I send a POST request to "/api/v1/import/submit.xml?import_type=STOCK" with the following:
    """
      <Items>
          <ItemStock SKU='959596794' Type='TOTAL'>
            <Qty>100</Qty>
          </ItemStock>
          <ItemStock SKU='959596791' Type='TOTAL'>
            <Qty>120</Qty>
          </ItemStock>
          <ItemStock SKU='95959671' Type='TOTAL'>
            <Qty>130</Qty>
          </ItemStock>
      </Items>
    """
    Then the result should have a "success" of "3"
    Then the response status should be "200"
    And I should have 1 item records with the attribute "group_stock" of "100"
    And I should have 1 item records with the attribute "group_stock" of "120"
    And I should have 1 item records with the attribute "group_stock" of "130"

    When I send a POST request to "/api/v1/import/submit.xml?import_type=STOCK" with the following:
    """
      <Items>
          <ItemStock SKU='959596794' Type='POSITIVE'>
            <Qty>100</Qty>
          </ItemStock>
          <ItemStock SKU='959596791' Type='POSITIVE'>
            <Qty>120</Qty>
          </ItemStock>
          <ItemStock SKU='95959671' Type='POSITIVE'>
            <Qty>130</Qty>
          </ItemStock>
      </Items>
    """
    Then the result should have a "success" of "3"
    Then the response status should be "200"
    And I should have 1 item records with the attribute "group_stock" of "200"
    And I should have 1 item records with the attribute "group_stock" of "240"
    And I should have 1 item records with the attribute "group_stock" of "260"

    When I send a POST request to "/api/v1/import/submit.xml?import_type=STOCK" with the following:
    """
      <Items>
          <ItemStock SKU='959596794' Type='NEGATIVE'>
            <Qty>100</Qty>
          </ItemStock>
          <ItemStock SKU='959596791' Type='NEGATIVE'>
            <Qty>120</Qty>
          </ItemStock>
          <ItemStock SKU='95959671' Type='NEGATIVE'>
            <Qty>130</Qty>
          </ItemStock>
      </Items>
    """
    Then the result should have a "success" of "3"
    Then the response status should be "200"
    And I should have 1 item records with the attribute "group_stock" of "100"
    And I should have 1 item records with the attribute "group_stock" of "120"
    And I should have 1 item records with the attribute "group_stock" of "130"


    When I send a POST request to "/api/v1/import/submit.xml?import_type=STOCK" with the following:
    """
      <Items>
          <ItemStock SKU='959596794' Type='TOTAL'>
            <Qty>1000</Qty>
          </ItemStock>
          <ItemStock SKU='959596791' Type='TOTAL'>
            <Qty>2000</Qty>
          </ItemStock>
          <ItemStock SKU='95959671' Type='TOTAL'>
            <Qty>3000</Qty>
          </ItemStock>
      </Items>
    """
    Then the result should have a "success" of "3"
    Then the response status should be "200"
    And I should have 1 item records with the attribute "group_stock" of "1000"
    And I should have 1 item records with the attribute "group_stock" of "2000"
    And I should have 1 item records with the attribute "group_stock" of "3000"

  Scenario: Import stock for three items - multiple item stock types
    When I send a POST request to "/api/v1/import/submit.xml?import_type=STOCK" with the following:
    """
      <Items>
          <ItemStock SKU='959596794' Type='TOTAL'>
            <Qty>100</Qty>
          </ItemStock>
          <ItemStock SKU='959596791' Type='TOTAL'>
            <Qty>120</Qty>
          </ItemStock>
          <ItemStock SKU='959596791' Type='POSITIVE'>
            <Qty>120</Qty>
          </ItemStock>
          <ItemStock SKU='95959671' Type='NEGATIVE'>
            <Qty>130</Qty>
          </ItemStock>
      </Items>
    """
    Then the result should have a "success" of "4"
    Then the response status should be "200"
    And I should have 1 item records with the attribute "group_stock" of "100"
    And I should have 1 item records with the attribute "group_stock" of "240"
    And I should have 1 item records with the attribute "group_stock" of "-130"

  Scenario: Import item inventory records
    When I send a POST request to "/api/v1/import/submit.xml?import_type=INVENTORY" with the following:
    """
      <Inventories>
          <Inventory SKU='959596794' Type='TOTAL' Location='LOCATION1'>
            <Qty>100</Qty>
          </Inventory>
          <Inventory SKU='959596791' Type='TOTAL' Location='LOCATION1'>
            <Qty>120</Qty>
          </Inventory>
          <Inventory SKU='959596791' Type='POSITIVE' Location='LOCATION1'>
            <Qty>120</Qty>
          </Inventory>
          <Inventory SKU='95959671' Type='NEGATIVE' Location='LOCATION1'>
            <Qty>130</Qty>
          </Inventory>
      </Inventories>
    """
    Then the result should have a "success" of "4"
    Then the response status should be "200"
    And I should have 1 item inventory records with the attribute "current_stock" of "100"
    And I should have 1 item inventory records with the attribute "current_stock" of "240"
    And I should have 1 item inventory records with the attribute "current_stock" of "-130"

  Scenario: Import item inventory records using reference
    When I send a POST request to "/api/v1/import/submit.xml?import_type=INVENTORY" with the following:
    """
      <Inventories>
          <Inventory SKU='959596794' Type='TOTAL' LocationReference='1'>
            <Qty>100</Qty>
          </Inventory>
          <Inventory SKU='959596791' Type='TOTAL' LocationReference='1'>
            <Qty>120</Qty>
          </Inventory>
          <Inventory SKU='959596791' Type='POSITIVE' LocationReference='1'>
            <Qty>120</Qty>
          </Inventory>
          <Inventory SKU='95959671' Type='NEGATIVE' LocationReference='1'>
            <Qty>130</Qty>
          </Inventory>
          <Inventory SKU='959596794' Type='TOTAL' LocationReference='2'>
            <Qty>100</Qty>
          </Inventory>
          <Inventory SKU='959596791' Type='TOTAL' LocationReference='2'>
            <Qty>120</Qty>
          </Inventory>
          <Inventory SKU='959596791' Type='POSITIVE' LocationReference='2'>
            <Qty>120</Qty>
          </Inventory>
          <Inventory SKU='95959671' Type='NEGATIVE' LocationReference='2'>
            <Qty>130</Qty>
          </Inventory>
      </Inventories>
    """
    Then the result should have a "success" of "8"
    Then the response status should be "200"
    And I should have 2 item inventory records with the attribute "current_stock" of "100"
    And I should have 2 item inventory records with the attribute "current_stock" of "240"
    And I should have 2 item inventory records with the attribute "current_stock" of "-130"

