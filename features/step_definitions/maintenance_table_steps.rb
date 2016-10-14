When /^(?:|I )([^"]*) the value "([^"]*)" on ([1-9][0-9]*)[snrt][tdh] row in column "([^"]*)"(?:| on row class "([^"]*)")$/ do |do_chk, t_value, t_row, t_det, row|
#(disabled|visible|enter|remove|edit|delete|show|report|select|should see|see|see selected|see text|
#should see selected|have no selector of|click|click image|checked|unchecked|see in grid)
  do_chk = do_chk.gsub(/I\s/, '')
  #puts "do_chk= #{do_chk}  value= #{t_value}  tbl row= #{t_row}  tbl col= #{t_det}  row= #{row}"
  if row != nil
    row_class = "//table//tr[starts-with(@class,'#{row}')]"
  else
    row_class = "//table//tr"
  end
  case do_chk
    when "disabled", "visible"
      tmp = page.find(:xpath, "//div#{row_class}[#{t_row}]/td[#{t_det.to_i}]")
      if do_chk == "disabled"
        assert tmp.has_xpath?(".//*[contains(attribute::disabled,'disabled') or contains(attribute::style,'display: none;')]")
      else
        assert tmp.has_no_xpath?(".//*[contains(attribute::disabled,'disabled') or contains(attribute::style,'display: none;')]")
      end

    when "remove", "edit", "delete", "show", "print", "cancel"
      if do_chk == "remove"
        page.find(:xpath, "#{row_class}[#{t_row}]//td[@class='remove']").click
      else
        # do_chk = "del" if do_chk == "delete"
        page.find(:xpath, "#{row_class}[#{t_row}]//td[#{t_det.to_i}]/a[contains(attribute::id, '#{do_chk}')] | #{row_class}[#{t_row}]//td[#{t_det.to_i}]/img[contains(attribute::id, '#{do_chk}')]").click
      end

    when "enter"
      tmp = page.find(:xpath, "//div#{row_class}[#{t_row}]/td//input[contains(attribute::id, '#{t_det.to_s}')] | //div#{row_class}[#{t_row}]/td//input[contains(attribute::class, '#{t_det.to_s}')]")
      tmp.set(t_value.to_s)

    when "select"
      tmp = page.find(:xpath, "//div#{row_class}[#{t_row}]/td//select[contains(attribute::id, '#{t_det.to_s}')] | //div#{row_class}[#{t_row}]/td//select[contains(attribute::class, '#{t_det.to_s}')]")
      within(tmp) { select(t_value.to_s) }

    when "see", "see text", "should see"
      if do_chk == "see text"
        tmp = page.find(:xpath, "//div#{row_class}[#{t_row}]/td[#{t_det.to_i}]")
      else
        tmp = page.find(:xpath, "//div#{row_class}[#{t_row}]/td//input[contains(attribute::id, '#{t_det.to_s}')]")
      end
      found = 0
      if t_value.to_s == 'empty'
        found = 1 if !(tmp.value.to_s == " " or tmp.value.to_s == "")
      elsif !(tmp.value.to_s == t_value.to_s or tmp.text.to_s == t_value.to_s)
        found = 1
      end

      if found == 1
        assert false, "For line #{t_row} item '#{t_det}' expected-> '#{t_value.to_s}' returned-> '#{tmp.value.to_s}#{tmp.text.to_s}'"
      end

    when "see selected", "should see selected"
      txt =page.find(:xpath, "//tr[starts-with(@class,'#{row}')][#{t_row}]/td/select[@id='#{t_det}']/option[@selected]")
      assert(false, "Expected '#{t_value.to_s}' selected but returned = '#{txt.text.to_s}' selected") if t_value.to_s != txt.text.to_s

    when "have no selector of"
      assert(false, "Did not expected '" + t_value.to_s + "' in the selection list") if page.has_content?(t_value.to_s)

    when "click"
      page.find(:xpath, "//div#{row_class}[#{t_row}]//td//input[contains(attribute::id, '#{t_det.to_s}')]").click

    when "click image"
      page.find(:xpath, "//div#{row_class}[#{t_row}]//td//img[contains(attribute::class, '#{t_det.to_s}')]").click

    when "checked"
      unless page.has_selector?(:xpath, "//div#{row_class}[#{t_row}]//td//input[contains(attribute::id, '#{t_det.to_s}')][contains(attribute::checked, 'yes')]")
        assert false, "Expected '#{t_det.to_s}' on row #{t_row} to be checked and it was not."
      end

    when "unchecked"
      unless page.has_no_selector?(:xpath, "//div#{row_class}[#{t_row}]//td//input[contains(attribute::id, '#{t_det.to_s}')][contains(attribute::checked, 'yes')]")
        assert false, "Expected '#{t_det.to_s}' on row #{t_row} to be unchecked and it was not."
      end

    when "see in grid"
      x=''; xy = ""
      x = page.find(:xpath, "//div//table//tr[@class='table-row'][#{t_row}]//td[#{t_det.to_i}]").text if page.has_xpath?("//div//table//tr[@class='table-row'][#{t_row}]//td[#{t_det.to_i}]")
      xy = page.find(:xpath, "//div#{row_class}[#{t_row}]//td[#{t_det.to_i}]").text if page.has_xpath?("//div#{row_class}[#{t_row}]//td[#{t_det.to_i}]")
      if x != t_value.to_s and xy != t_value.to_s
        assert false, "Expected '#{t_value.to_s}' - returned = '#{(xy.blank?) ? x : xy}'"
      end
    else
      assert false, "Not a recognised event '#{do_chk}'"
  end
end

When /^(?:|I )click (edit|show|delete|clone|close|cancel) for the ([^"]*) with ([^"]*) "([^"]*)"(?:| in company "([^"]*)")$/ do |option, table, column, value, company|
  step "wait 10 seconds for \"Processing\" to finish"
  column.gsub!(/\s/, '_')
  table.gsub!(/\s/, '_')
  table = table.camelize
  column.downcase!
  append = ""
  case table
    when "User", "Company"
      if company.present?
        if company == "all"
          tmp = "#{table}.where('company_id is null').find_by_#{column}('#{value.to_s}').id"
        else
          company_id = Company.find_by_name(company).id if company != "all"
          tmp = "#{table}.find_by_#{column}_and_company_id('#{value.to_s}','#{company_id.to_s}').id"
        end
      else
        tmp = table + ".find_by_#{column}('#{value.to_s}').id"
      end
      if option == "delete" and table != "User"
        append = "#{eval(tmp)}"
      else
        append = "#{table.underscore}_#{eval(tmp)}"
      end
    else
      if company.present?
        tmp = "#{table}.where('company_id is null').find_by_#{column}('#{value.to_s}').id" if company == "all"
        company_id = Company.find_by_name(company).id if company != "all"
        tmp = "#{table}.find_by_#{column}_and_company_id('#{value.to_s}','#{company_id.to_s}').id" if company != "all"
        append = eval(tmp)
      else
        tmp = table + ".find_by_#{column}('#{value.to_s}').id"
        append = eval(tmp)
      end
  end

  link_id = "#{option}_#{append.to_s}"
  step("wait 10 seconds for element with id of \"#{link_id}\" to appear")
  begin
    Timeout::timeout(120) {
      find(:xpath, "//*[@id='#{link_id}']").click
    }
  rescue Timeout::Error
    puts 'That took too long, to click the link and recover...'
    find(:xpath, "//*[@id='#{link_id}']").click
  end

end


Then /^there should be (\d+) visible rows? in the table with id "([^"]*)"$/ do |rows, table|
  actual_count = page.all(:xpath, "//table[@id='#{table}']/tbody/tr[not(contains(@style,'display: none'))and not(contains(@style,'display:none'))]").count.to_i
  actual_count -= page.all(:xpath, "//table[@id='#{table}']/tbody/tr/td[@class='dataTables_empty']").count.to_i
  if actual_count != rows.to_i
    assert false, "Expected #{rows} rows, but #{actual_count} rows were found."
  end
end



