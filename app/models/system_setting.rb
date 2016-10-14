class SystemSetting < ActiveRecord::Base
  validates_uniqueness_of :setting_code
  has_many :company_settings

  def self.check_setting(setting, default=false, company_id)
    system_setting = SystemSetting.find_by_setting_code(setting)
    company_id = Thread.current[:company_id] if company_id.blank? and Thread.current[:company_id].present?
    if system_setting.present?
      company_setting = CompanySetting.find_by_company_id_and_system_setting_id(company_id, system_setting.id)
      if company_setting.present?
        if company_setting.system_setting.setting_type == 'B'
          if company_setting.value == "Y"
            return true
          else
            return false
          end
        else
          return company_setting.value
        end
      else
        if system_setting.setting_type == 'B'
          if system_setting.value == "Y"
            return true
          else
            return false
          end
        else
          return system_setting.value
        end
      end
    else
      return default
    end
  end


  def self.process_xml(data)
    require 'rexml/document'
    doc = REXML::Document.new(data)

    #   <Setting>
    #   <Code>pn_with_integrated_labels</Code>
    #   <Description>Print Integrated Labels On Pick Notes</Description>
    #   <Group>Order Processing</Group>
    #   <Value>Y</Value>
    #   <Type>B</Type>
    # </Setting>

    doc.elements.each('Settings/Setting') do |parameter|
      sys_param = self.find_or_initialize_by_setting_code(parameter.elements['Code'].text)
      sys_param.setting_description = parameter.elements['Description'].text if parameter.elements['Description'].present?
      sys_param.value = parameter.elements['Value'].text if parameter.elements['Value'].present?
      sys_param.setting_group = parameter.elements['Group'].text if parameter.elements['Group'].present?
      sys_param.setting_type = parameter.elements['Type'].text if parameter.elements['Type'].present?
      sys_param.save!
    end
  end

  def self.update_settings
    data = File.read("#{Rails.root}/import/XML/system_settings.xml")
    SystemSetting.process_xml(data)
  end

end
