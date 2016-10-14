# encoding: utf-8

After('@pause_at_end , @pauseatend, @pae') do
  print "Press Return to continue\n"
  STDIN.getc
end

Before('@speed_slow') do
  set_speed(:slow)
end

Before('@speed_fast') do
  set_speed(:fast)
end


Before('@javascript') do
  Capybara.reset!
  Capybara.use_default_driver
  page.driver.browser.manage.window.maximize
  #window = Capybara.current_session.driver.browser.manage.window
  #window.resize_to(1200, 800)

  set_speed(:medium)
end

Before('@racktest') do
  Capybara.current_driver = :rack_test
  set_speed(:medium)
end
After('@racktest') do
  Capybara.use_default_driver
end

## AFTER A SCENARIO FAIL STORE THE SCREENSHOT
After do |scenario|
  fname = ""
  if scenario.status != :passed
    if scenario.respond_to?('title') or scenario.scenario_outline.respond_to?('title')
      fname = "#{scenario.feature.title}__#{scenario.title}" if scenario.respond_to?('title') rescue false
      fname = "#{scenario.scenario_outline.feature.title}__#{scenario.scenario_outline.name}" if scenario.scenario_outline.respond_to?('title') rescue false
      fname.gsub!(/[\x00\/\\:\*\?"<%>\|\.]/, '')

      path = "#{Rails.root}/cucumber_pictures/"
      FileUtils.mkpath(path)
      file = "#{path}/#{fname[0, 249]}.jpeg"
      begin
        if os == :macosx
          %x[screencapture "#{file}"]
        else
          %x[scrot "#{file}"]
        end
      rescue => e
        puts "Not enough memory to do a screen shot at this time".red if e.message.include? 'Cannot allocate memory - scrot'
        raise e unless e.message.include? 'Cannot allocate memory - scrot'
      end
    end
  end
  unless page.has_no_content?("Server Error")
    print "Scenario failed due to a server error reported\n".red
    print "#{page.text.to_s.red}\n"
  end
  sleep 1 # wait for db to finish processing
  #clear local storage
  Capybara.current_session.driver.execute_script("localStorage.clear()") rescue nil
  #Close any extra open tabs
  while page.driver.browser.window_handles.size > 1 && @s_pause == false
    page.driver.browser.switch_to.window(page.driver.browser.window_handles.last)
    page.driver.browser.close
    page.driver.browser.switch_to.window(page.driver.browser.window_handles.first)
  end
end

at_exit do
  sleep 0.1
  if $!.nil? || $!.is_a?(SystemExit) && $!.success?
    puts 'Feature scenario(s) successful run through...'
  end
  SystemExit
end

require 'rbconfig'

def os
  @os ||= (
  host_os = RbConfig::CONFIG['host_os']
  case host_os
    when /mswin|msys|mingw|cygwin|bccwin|wince|emc/
      :windows
    when /darwin|mac os/
      :macosx
    when /linux/
      :linux
    when /solaris|bsd/
      :unix
    else
      raise Error::WebDriverError, "unknown os: #{host_os.inspect}"
  end
  )
end

