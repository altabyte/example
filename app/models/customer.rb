class Customer < ActiveRecord::Base
  include CompanyOnly

  has_many :customer_addresses, :dependent => :destroy
  # has_many :billing_addresses, :class_name => 'CustomerAddress', :conditions => "address_type = 'SHIPPING'"
  has_many :users
  has_many :items
  has_many :channels
  has_many :customers
  validates_uniqueness_of :email, :scope => :channel_id
  validates_presence_of :email
  accepts_nested_attributes_for :customer_addresses, :allow_destroy => true

  scope :by_company, lambda { |company_id|
                     where(['company_id NOT IN (?)', company_id]) if company_id.present?
                   }
end
