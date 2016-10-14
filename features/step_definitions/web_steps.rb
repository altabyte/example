require 'uri'
require 'cgi'
require File.expand_path(File.join(File.dirname(__FILE__), "..", "support", "paths"))
require File.expand_path(File.join(File.dirname(__FILE__), "..", "support", "selectors"))

module WithinHelpers
  def with_scope(locator)
    step("wait 10 seconds for #{locator} to appear") if locator
    locator = selector_for(locator) rescue locator
    locator ? within(*locator) { yield } : yield
  end
end
World(WithinHelpers)
Capybara.ignore_hidden_elements = true

When /^(.*) within ([^:^"]+)$/ do |step_x, parent|
  with_scope(parent) { step step_x }
end


Given /^(?:|I )am on (.+)$/ do |page_name|
  time = 10
  time = @g_time if @g_time != nil or @g_time.to_i >= 1
  end_time=Time.now.to_i+time.to_i
  found = 0
  visit path_to(page_name)
  while Time.now.to_i < end_time and found == 0 do
    current_path = URI.parse(current_url).path
    found = 1 if current_path == path_to(page_name)
  end
  if found == 0
    puts "#{time} second timeout hit while waiting for path '#{page_name.to_s}'\ncurrent page = \n'#{current_path.to_s}'"
    assert path_to(page_name)
  end
end

When /^(?:|I )follow "([^"]*)"$/ do |link|
  step "wait 5 seconds for link \"#{link}\" to appear"
  page.find(:xpath, ".//a[(((./@id = '#{link}' or normalize-space(string(.)) = '#{link}') or ./@title = '#{link}') or .//img[./@alt = '#{link}'])] | .//a[(((./@id = '#{link}' or contains(normalize-space(string(.)), '#{link}')) or contains(./@title, '#{link}')) or .//img[contains(./@alt, '#{link}')])] | .//a[contains(., '#{link}')]").click
end

When /^(?:|I )fill in "([^"]*)" with "(.*)"$/ do |field, value|
  end_time=Time.now + 5.seconds
  panel = nil
  found = nil
  while Time.now < end_time and !found
    if page.has_field?(field)
      found = 1
    elsif page.has_xpath?("//div[@id='#{field}'] | //span[.='#{field}']/parent::div[@class='x-form-label']/parent::div")
      found = 1
      panel = page.find(:xpath, "//div[@id='#{field}'] | //span[.='#{field}']/parent::div[@class='x-form-label']/parent::div")
    end
  end

  if panel.present?
    field = panel.find(:xpath, "./descendant::input")[:id]
  end

  fill_in(field, :with => value)
  #Check if the value has been entered and if not (probably be cause it is of type number number) enter the keystrokes.
  x = page.find_field(field)
  if page.has_field?(field, :with => value) == false and x.value.to_f != value.to_f
    #  puts "try to fill via native send key"
    value.each_char do |c|
      x.native.send_key(c)
    end
  end
  x.native.send_key(:backspace) if value.blank?
end

When /^(?:|I )select "([^"]*)" from "([^"]*)"$/ do |value, field|
  #select(value, :from => field)
  sel = find(:select, field)
  assert_match(value, sel.text, "Select expected '#{value}' but only has options '#{sel.text}'")
  sel.first(:option, value).select_option
  if value == "Yes"
    sleep 0.3
  end
end

When /^(?:|I )select "([^"]*)" from select with class "([^"]*)"$/ do |value, field|
  #select(value, :from => field)
  sel = find(:css, ".#{field}")
  assert_match(value, sel.text, "Select expected '#{value}' but only has options '#{sel.text}'")
  sel.first(:option, value).select_option
  if value == "Yes" and field == "Sellable"
    sleep 0.3
  end
end

When /^(?:|I )attach the file "([^"]*)" to "([^"]*)"$/ do |path, field|
  attach_file(field, File.expand_path(path), visible: false)
end

Then /^(?:|I )should( not)? see "(.+)"$/ do |boolean, text|
  found_snippets = []
  expected_snippets = text.split('", "')
  time = @g_time || 10
  end_time = Time.now + time.seconds

  while Time.now < end_time and !boolean do
    if page.has_content?(expected_snippets.first)
      end_time = Time.now
    end
    sleep 0.1
  end

  expected_snippets.each do |snippet|
    if page.has_content?(snippet)
      found_snippets << snippet
    end
  end

  errors = boolean ? expected_snippets & found_snippets : expected_snippets - found_snippets
  message = "I should#{boolean} see the following: #{errors}"
  assert(errors.empty?, message)
end

Then /^(?:|I )should be on (.+)$/ do |page_name|
  time = 20
  time = @g_time if @g_time != nil or @g_time.to_i >= 1
  end_time=Time.now.to_i+time.to_i
  found = 0
  while Time.now.to_i < end_time and found == 0 do
    current_path = URI.parse(current_url).path
    found = 1 if current_path == path_to(page_name)
  end
  message = "#{time} second timeout hit while waiting for path '#{page_name.to_s}'\ncurrent page = \n'#{current_path.to_s}'"
  assert(found == 1, message)
end
