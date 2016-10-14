When /^(?:|I )wait ([^"]*) seconds? for ([^"]*) to appear$/ do |time, text|
  time = @g_time if @g_time != nil
  end_time= Time.now.to_f + time.to_f
  found = 0
  txt = selector_for(text) rescue text
  if time.to_f > 0
    while Time.now.to_f < end_time and found == 0 do
      if time.to_f > 0
        found = 1 if page.has_css?(txt, :visible => true) or page.has_field?(txt, :visible => true) #or page.has_button?(txt) or page.has_link?(txt) or page.has_checked_field?(txt)
        sleep (0.2) if found == 0
      end
    end

    if found == 0
      assert(false, "#{time} second timeout hit while waiting for \"#{text}\" to appear") if found == 0
    else
      assert(true)
    end
  end
end


When /^(?:|I )wait ([^"]*) seconds? for element with (id|class|href) of "([^"]*)" to appear$/ do |time, id_class, text|
  time = @g_time if @g_time != nil
  end_time=Time.now.to_i+time.to_i
  found = 0
  if time.to_f > 0
    while Time.now.to_i < end_time and found == 0 do
      sleep (0.3)
      case id_class
        when "class"
          found = 1 if page.has_css?(".#{text}")
        when "id"
          found = 1 if page.has_css?("##{text}")
        else
          found = 1 if page.has_xpath?("//div//a[contains(attribute::href, '#{text}')]")
      end
    end
  end
  assert(false, "#{time} second timeout hit while waiting for element with #{id_class} of \"#{text}\" to appear") if found == 0
end


When /^(?:|I )wait ([^"]*) seconds? for "([^"]*)" to finish$/ do |time, txt|
  time = @g_time if @g_time != nil
  end_time = Time.now.to_i + time.to_i
  found = 0
  if time.to_f > 0
    sleep 0.2 # give time for text to load
    while Time.now.to_i < end_time and found == 0 do
      found = 1 if page.has_no_content?(txt)
    end
    assert(found == 1, "#{time} second timeout hit while waiting for \"#{txt}\" to finish")
  end
end


When /^(?:|I )wait ([^"]*) seconds? for link "([^"]*)" to appear$/ do |time, link|
  time = @g_time if @g_time != nil
  end_time=Time.now.to_i+time.to_i
  found = 0
  if time.to_f > 0
    while Time.now.to_i < end_time and found == 0 do
      sleep (0.1)
      found = 1 if page.has_xpath?(".//a[(((./@id = '#{link}' or normalize-space(string(.)) = '#{link}') or ./@title = '#{link}') or .//img[./@alt = '#{link}'])] | .//a[(((./@id = '#{link}' or contains(normalize-space(string(.)), '#{link}')) or contains(./@title, '#{link}')) or .//img[contains(./@alt, '#{link}')])] | .//a[contains(., '#{link}')]")
    end
    assert(false, "#{time} second timeout hit while waiting for link \"#{link}\" to appear") if found == 0
  end
end

When /^(?:|I )wait ([^"]*) seconds?$/ do |num|
  sleep num.to_f
end