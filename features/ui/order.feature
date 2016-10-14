@javascript
@speed_fast
@ui

Feature: Basic order checks

  Background:
    Given I send and accept XML
    Given I use the authentication token for "admin@ordermanager.biz"
    When I send a POST request to "/api/v1/import/submit.xml?import_type=ORDER" with the following:
    """
      <Orders>
        <Order ChannelID='1' ChannelName='WWW'>
            <OrderID>SD1100004816</OrderID>
            <ShippingService>Select Shipping Method - Standard Shipping (1-3 Days)</ShippingService>
            <OrderDate>2014-01-01 08:41:05</OrderDate>
            <OrderStatus>Processing</OrderStatus>
            <OrderTotal>115.5000</OrderTotal>
            <OrderSubTotal>96.2500</OrderSubTotal>
            <OrderShippingCost>0.0000</OrderShippingCost>
            <OrderVatAmount>19.2500</OrderVatAmount>
            <Customer>
              <FullName>Patricia Cooper</FullName>
              <email>pacpostbox@aol.com</email>
            </Customer>
            <ShippingAddress AddressID='8828'>
              <Name>Patricia  Cooper</Name>
              <AddressLine1>3 Paddock Walk</AddressLine1>
              <AddressLine2/>
              <Town>WARLINGHAM</Town>
              <Company/>
              <County>Surrey</County>
              <Country>GB</Country>
              <PostCode>CR6 9HW</PostCode>
              <Telephone>01883622574</Telephone>
            </ShippingAddress>
            <BillingAddress AddressID='8827'>
              <AddressLine1>3 Paddock Walk</AddressLine1>
              <AddressLine2/>
              <Town>WARLINGHAM</Town>
              <Company/>
              <County>Surrey</County>
              <Country>GB</Country>
              <PostCode>CR6 9HW</PostCode>
              <Telephone>01883622574</Telephone>
            </BillingAddress>
            <OrderItems>
              <OrderItem OrderDetailID='27560'>
                <SKU>7383807</SKU>
                <ItemName>Tommy Hilfiger Maine Down Puffa Hooded Gilet In Navy - Size L</ItemName>
                <Colour>NAVY</Colour>
                <Size>18 - L</Size>
                <QtyOrdered>1</QtyOrdered>
                <UnitPrice>96.2500</UnitPrice>
                <VatAmount>19.2500</VatAmount>
                <HarmonizationCode/>
                <CountyOfOrigin/>
                <ItemWeight/>
                <GiftWrapLevel/>
                <GiftWrapPrice/>
                <GiftWrapMessage/>
              </OrderItem>
            </OrderItems>
            <FraudScore>
              <LastFourDigits>4851</LastFourDigits>
              <AVSCV2>ALL MATCH</AVSCV2>
              <AddressResult>MATCHED</AddressResult>
              <PostcodeResult>MATCHED</PostcodeResult>
              <CV2Result>MATCHED</CV2Result>
              <ThreedSecureStatus>ATTEMPTONLY</ThreedSecureStatus>
              <ThirdmanAction>OK</ThirdmanAction>
              <ThirdmanScore>-49</ThirdmanScore>
            </FraudScore>
          </Order>
      </Orders>
      """
    Then the result should have a "success" of "1"
    Then the response status should be "200"
    And I should have 1 order records with the attribute "company_id" of "1"
    And I should have 1 item records with the attribute "company_id" of "1"

  Scenario: Import 1 order and check company awareness
    Given I am logged in as the USER user
    When I follow "Orders" within the navigation menu
    When I follow "1 > Orders"
    Then I should be on the orders page
    Then I should see "New Shipping Services Found"
    And   I press the alertify ok button
    When I select "Post Office" from select with class "shipping_service_select"
    And I press the maintenance save button
    Then I should see "Showing 1 to 1 of 1 entries"
    And I see in grid the value "SD1100004816" on 1st row in column "4"
    Then I press the logout button
    Given I am logged in as the USER2 user
    When I follow "Orders" within the navigation menu
    When I follow "1 > Orders"
    Then I should be on the orders page
    Then I should see "Showing 0 to 0 of 0 entries"
    Then  I should not see "SD1100004816"





