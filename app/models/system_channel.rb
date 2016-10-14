class SystemChannel < ActiveRecord::Base

  has_many :channels
  has_one :system_channel_setting
  validates_uniqueness_of :name
  validates_presence_of :name
end
