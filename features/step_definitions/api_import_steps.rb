Then /^the result should have a "([^"]*)" of "([^"]*)"$/ do |field, value|
  if last_response.headers['Content-Type'] =~ /json/
    puts JSON.pretty_generate(response_as_json)
  elsif last_response.headers['Content-Type'] =~ /xml/
    xml_doc = Nokogiri::XML(last_response.body)
    result_code = xml_doc.xpath("//#{field}")
    puts last_response.body
    if result_code.present?
      assert(result_code.text == value, "#{field} not equal #{value}")
    else
      assert(result_code.present?, "Result Missing #{field}")
    end
  end
end