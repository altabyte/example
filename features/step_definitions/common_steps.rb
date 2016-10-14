When /^(?:|I )press ([^"]*)$/ do |buttons|
  buttons.split(' -> ').each do |button|
    step("wait 10 seconds for #{button} to appear")
    page.find(selector_for(button)).click
  end
end


Then /^(?:|I )should( not)? see ([^"]*)$/ do |boolean, components|
  found_components = Array.new
  expected_components = components.split(', ')
  time = @g_time || 10
  end_time = Time.now + time.seconds

  while Time.now < end_time and !boolean do
    if page.has_css?(selector_for(expected_components.first))
      end_time = Time.now
    end
    sleep 0.1
  end

  expected_components.each do |component|
    found_components << component if page.has_css?(selector_for(component))
  end

  errors = boolean ? expected_components & found_components : expected_components - found_components
  message = "I should#{boolean} see the following: #{errors}"
  assert(errors.empty?, message)
end

When /^(?:|I )select "([^"]*)" from ([^"]*)$/ do |value, field|
  locator=""
  selector_for(field).each_char do |c|
    locator << c.chr unless c.chr == "#"
  end
  sel = find(:select, locator)
  assert_match(value, sel.text, "Select expected '#{value}' but only has options '#{sel.text}'")
  sel.first(:option, value).select_option
end

When /^(?:|I )fill in ([^"]*) with "([^"]*)"$/ do |field, value|
  step("wait 10 seconds for #{field} to appear")
  find(selector_for(field)).set value.to_s
end

When /^(?:|I )visit the path "([^"]*)"$/ do |path|
  visit (path)
end


When /^(?:|I )click the (\d+)[snrt][tdh] instance of ([^"]*)$/ do |count, locator|
  step ("wait 10 seconds for #{locator} to appear")
  page.all(selector_for(locator))[count.to_i-1].click
end


Then /^the dropdown "([^"]*)" should contain( exactly)? the options? (.+)$/ do |dropdown, exact, options|

  result = page.has_select?(dropdown)
  message = "Dropdown #{dropdown} not found."
  assert(result.present?, message)

  option_array = options.split(', ')
  if exact
    result = page.has_select?(dropdown, :options => option_array, :visible => true)
    message = "The list of options in the dropdown #{dropdown} doesn't exactly match #{options.gsub(", ", " ")} found '#{find(:select, dropdown, :visible => true).text.to_s}'"
  else
    result = page.has_select?(dropdown, :with_options => option_array)
    message = "The options in the dropdown #{dropdown} doesn't contain #{options.gsub(", ", " ")} found '#{find(:select, dropdown).text.to_s}'"
  end
  assert(result, message)

end