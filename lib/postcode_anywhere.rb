require 'net/http'
require 'rexml/document'

module PostCodeAnywhere
  def self.CapturePlus_Interactive_Find_v2_00(key, searchterm, lastid, searchfor, country, languagepreference)

    #Build the url
    requestUrl = "http://services.postcodeanywhere.co.uk/CapturePlus/Interactive/Find/v2.00/xmle.ws?"
    requestUrl += "&key=#{key}"
    requestUrl += "&searchterm=#{searchterm}"
    requestUrl += "&lastid=#{lastid}"
    requestUrl += "&searchfor=#{searchfor}"
    requestUrl += "&country=#{country}"
    requestUrl += "&languagepreference=#{languagepreference}"

    #Get the data
    begin
      xml_results = Net::HTTP.get_response(URI.parse(URI.encode(requestUrl.strip)))
    rescue Exception => e
      puts 'Error: ' + e.message
    end

    if xml_results.present?
      #Parse to xml
      results = REXML::Document.new(xml_results.body)
      entries = Array.new

      results.elements.each('Table/Row') do |row|
        entry = Array.new

        #Check for errors
        row.elements.each('Error') do |element|
          row.elements.each('Description') do |element|
            puts 'Error: ' + element.text
            return
          end
        end

        if row.elements['Next'].text == 'Find'
          self.CapturePlus_Interactive_Find_v2_00(key, searchterm, row.elements['Id'].text, searchfor, country, languagepreference).each do |record|
            entries << record
          end
        else
          entries << {
              :id => row.elements['Id'].text,
              :text => row.elements['Text'].text,
              :highlight => row.elements['Highlight'].text,
              :cursor => row.elements['Cursor'].text,
              :description => row.elements['Description'].text,
              :next => row.elements['Next'].text
          }
        end
      end
      return entries
    else
      #return 'dnbo'
    end
  end

  def self.CapturePlus_Interactive_Retrieve_v2_00(key, id)

    #Build the url
    requestUrl = "http://services.postcodeanywhere.co.uk/CapturePlus/Interactive/Retrieve/v2.00/xmle.ws?"
    requestUrl += "&key=#{key}"
    requestUrl += "&id=#{id}"

    #Get the data
    begin
      xml_results = Net::HTTP.get_response(URI.parse(URI.encode(requestUrl.strip)))
    rescue Exception => e
      puts 'Error: ' + e.message
    end

    #Parse to xml
    results = REXML::Document.new(xml_results.body)
    entries = Array.new

    #Read into arrays
    results.elements.each('Table/Row') do |row|
      entry = Array.new

      #Check for errors
      row.elements.each('Error') do |element|
        row.elements.each('Description') do |element|
          puts 'Error: ' + element.text
          return
        end
      end

      entries << {
          :id => row.elements['Id'].text,
          :company => row.elements['Company'].text,
          :line_1 => row.elements['Line1'].text,
          :line_2 => row.elements['Line2'].text,
          :province => row.elements['Province'].text,
          :city => row.elements['City'].text,
          :post_code => row.elements['PostalCode'].text,
          :country_name => row.elements['CountryName'].text,
          :country_iso2 => row.elements['CountryIso2'].text
      }
    end

    return entries

  end
end
