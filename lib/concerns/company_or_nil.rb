module CompanyOrNil
  extend ActiveSupport::Concern

  included do
    default_scope {
      where("#{table_name}.company_id = ? or #{table_name}.company_id IS NULL", Thread.current[:company_id]).readonly(false) unless (Thread.current[:company_id].nil?)
    }
  end


end