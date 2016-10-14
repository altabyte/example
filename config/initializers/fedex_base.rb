module Fedex
  module Request
    class Base
      #include Helpers
      #include HTTParty
      #format :xml
      ## If true the rate method will return the complete response from the Fedex Web Service
      #attr_accessor :debug
      ## Fedex Text URL
      #TEST_URL = "https://gatewaybeta.fedex.com:443/xml/"
      #
      ## Fedex Production URL
      #PRODUCTION_URL = "https://gateway.fedex.com:443/xml/"
      #
      ## List of available Service Types
      #SERVICE_TYPES = %w(EUROPE_FIRST_INTERNATIONAL_PRIORITY FEDEX_1_DAY_FREIGHT FEDEX_2_DAY FEDEX_2_DAY_AM FEDEX_2_DAY_FREIGHT FEDEX_3_DAY_FREIGHT FEDEX_EXPRESS_SAVER FEDEX_FIRST_FREIGHT FEDEX_FREIGHT_ECONOMY FEDEX_FREIGHT_PRIORITY FEDEX_GROUND FIRST_OVERNIGHT GROUND_HOME_DELIVERY INTERNATIONAL_ECONOMY INTERNATIONAL_ECONOMY_FREIGHT INTERNATIONAL_FIRST INTERNATIONAL_PRIORITY INTERNATIONAL_PRIORITY_FREIGHT PRIORITY_OVERNIGHT SMART_POST STANDARD_OVERNIGHT)
      #
      ## List of available Packaging Type
      #PACKAGING_TYPES = %w(FEDEX_10KG_BOX FEDEX_25KG_BOX FEDEX_BOX FEDEX_ENVELOPE FEDEX_PAK FEDEX_TUBE YOUR_PACKAGING)
      #
      ## List of available DropOffTypes
      #DROP_OFF_TYPES = %w(BUSINESS_SERVICE_CENTER DROP_BOX REGULAR_PICKUP REQUEST_COURIER STATION)
      #
      ## Clearance Brokerage Type
      #CLEARANCE_BROKERAGE_TYPE = %w(BROKER_INCLUSIVE BROKER_INCLUSIVE_NON_RESIDENT_IMPORTER BROKER_SELECT BROKER_SELECT_NON_RESIDENT_IMPORTER BROKER_UNASSIGNED)
      #
      ## Recipient Custom ID Type
      #RECIPIENT_CUSTOM_ID_TYPE = %w(COMPANY INDIVIDUAL PASSPORT)

      # In order to use Fedex rates API you must first apply for a developer(and later production keys),
      # Visit {http://www.fedex.com/us/developer/ Fedex Developer Center} for more information about how to obtain your keys.
      # @param [String] key - Fedex web service key
      # @param [String] password - Fedex password
      # @param [String] account_number - Fedex account_number
      # @param [String] meter - Fedex meter number
      # @param [String] mode - [development/production]
      #
      # return a Fedex::Request::Base object
      def initialize(credentials, options={})
        requires!(options, :shipper, :recipient, :packages)
        @credentials = credentials
        @shipper, @recipient, @packages, @service_type, @customs_clearance, @debug = options[:shipper], options[:recipient], options[:packages], options[:service_type], options[:customs_clearance], options[:debug]
        @shipping_options = options[:shipping_options] ||={}
        # Expects hash with addr and port
        if options[:http_proxy]
          self.class.http_proxy options[:http_proxy][:host], options[:http_proxy][:port]
        end
      end
    end
  end
end
