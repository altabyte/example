@api

Feature: API Import Items
  Import data via API Endpoints

  Background:
    Given I send and accept XML
    Given I use the authentication token for "admin@ordermanager.biz"

  Scenario: Import three items
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
    Then the result should have a "success" of "3"
    Then the response status should be "200"
    And I should have 3 item records with the attribute "company_id" of "1"

  Scenario: Import items with one invalid sku
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
          <Item>
              <SKU></SKU>
              <ItemName>Test Item 2</ItemName>
          </Item>
      </Items>
    """
    Then the result should have a "success" of "3"
    Then the result should have a "failed" of "1"
    Then the response status should be "200"
    And I should have 3 item records with the attribute "company_id" of "1"

  Scenario: Import items with one invalid itemname
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
          <Item>
              <SKU>4242434244243</SKU>
              <ItemName></ItemName>
          </Item>
      </Items>
    """
    Then the result should have a "success" of "3"
    Then the result should have a "failed" of "1"
    Then the response status should be "200"
    And I should have 3 item records with the attribute "company_id" of "1"

  Scenario: Import three items with one update
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
          <Item>
              <SKU>95959671</SKU>
              <ItemName>Test Item 2</ItemName>
              <HarmonizationCode>42424244242</HarmonizationCode>
              <CountryCode>US</CountryCode>
              <ItemWeight>1.5</ItemWeight>
          </Item>
      </Items>
    """
    Then the result should have a "success" of "4"
    Then the result should have a "failed" of "0"
    Then the response status should be "200"
    And I should have 3 item records with the attribute "company_id" of "1"
    Then the 3rd item record should have a "harmonization_code" value of "42424244242"

