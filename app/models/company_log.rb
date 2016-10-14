class CompanyLog < ActiveRecord::Base
  attr_accessible :company_id, :date_timestamp, :log_level, :message
  belongs_to :company
end
