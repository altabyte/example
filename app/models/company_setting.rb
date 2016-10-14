class CompanySetting < ActiveRecord::Base
  attr_accessible :system_setting_id, :value, :company_id

  belongs_to :system_setting
  belongs_to :company
end
