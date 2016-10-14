module CompanyOnly
  extend ActiveSupport::Concern

  included do
    default_scope {
      where("#{table_name}.company_id = ?", Thread.current[:company_id]).readonly(false) unless (Thread.current[:company_id].nil?)
    }
  end


end