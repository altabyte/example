Then /^the ([1-9][0-9]*)[snrt][tdh] ([^"]*) record should have a "([^"]*)" value of "([^"]*)"$/ do |num, t, c, expected|

  model = t.tr(' ', '_').camelize.constantize
  record = model.all[num.to_i-1] rescue nil

  message = "#{num.to_i.ordinalize} row of the table #{t} not found"
  assert(record.present?, message)

  actual = record.send(c) || "" # DO NOT rescue nil this, it should fail if needs be!

  message = "Expected #{c} to equal \"#{expected}\", but equals \"#{actual}\""
  assert(actual.to_s == expected, message)
end

Then /^(?:|I )should have (\d+) ([^"]*) records? with the attribute "([^"]*)" of "([^"]*)"$/ do |expected, table, condition_field, condition_value|
  if table == "user"
    if condition_field == "company"
      company = Company.find_by_name(condition_value)
      condition_value = company.id if company.present?
      condition_field = "company_id" if company.present?
    end
  end
  model = table.tr(' ', '_').camelize.constantize
  actual = model.where("#{condition_field} = ?", condition_value).count.to_s
  message = "Expected #{expected} #{table} record(s), but found #{actual}"
  assert(actual == expected, message)
end

Given /^(?:|I )should have (\d+) users with user role "([^"]*)"$/ do |expected, role|
  role = Role.find_by_name(role)
  actual = User.unscoped.where("role_id = ?", role.id).count
  message = "Expected #{expected} users with #{role.name} role, but found #{actual}"
  assert(expected.to_i==actual, message)
end

Given /^(?:|I )set ([^"]*) to "([^"]*)" for the ([^"]*) record where "([^"]*)"$/ do |column, value, table, condition|
  model = table.tr(' ', '_').camelize.constantize
  record = model.where(condition).first
  message = "#{table} record with #{condition} not found!"
  assert(record.present?, message)
  line = "record.#{column}='#{value}'"
  eval(line)
  record.save!
end

Given /(?:|I )change the setting "([^"]*)" for user "([^"]*)" to "([^"]*)"$/ do |setting, user, value|
  user = User.find_by_email(user)
  system_setting = SystemSetting.find_by_setting_code(setting)
  if user.present? and system_setting.present?

    if user.company_id.present?
      company_setting = CompanySetting.find_or_initialize_by_company_id_and_system_setting_id(user.company_id, system_setting.id)
      company_setting.value = value
      company_setting.save
    else
      system_setting.value = value
      system_setting.save
    end
  end
end

Then /^(?:|I )should have ([0-9]*) ([^"]*) records?$/ do |count, model|
  model.gsub!(/\s/, '_')
  @model = model.camelize.constantize
  actual = @model.count

  message = "Expected #{count} lines, but found #{actual}."
  assert(count.to_i == actual.to_i, message)
end

Given /(?:|I )have stock location "([^"]*)" in company "([^"]*)"$/ do |name, company|
  company = Company.find_by_name(company)

  unless company.nil?
    loc = StockLocation.find_all_by_company_id_and_name(company.id, name)
    if loc.empty?

      max_ref = StockLocation.where("company_id = ?", company.id).maximum(:reference)
      max_ref = 1 if max_ref.blank?

      StockLocation.create(
          :name => name,
          :company_id => company.id,
          :reference => max_ref
      )
    else
      puts "Stock Location '#{name }' already exists for company '#{company}'"
    end
  end
end