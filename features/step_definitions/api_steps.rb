Given /^(?:|I )send and accept (XML|JSON)$/ do |type|
  begin
    header 'Accept', "application/#{type.downcase}"
    header 'Content-Type', "application/#{type.downcase}"

  rescue
    puts "set headers failed"
  end
end

When /^(?:|I )send a (GET|POST|PUT|DELETE) request (?:for|to) "([^"]*)" with the following:?$/ do |request_type, path, input|
  api_request(request_type, path, input)
end

Then /^(?:|I )use the authentication token for "([^"]*)"$/ do |email|
  @auth_token = User.find_by_email(email).authentication_token
end

Then /^the response status should be "([^"]*)"$/ do |status|
  if self.respond_to? :should
    last_response.status.should == status.to_i
  else
    assert_equal status.to_i, last_response.status
  end
end
