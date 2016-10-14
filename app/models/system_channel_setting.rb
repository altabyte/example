class SystemChannelSetting < ActiveRecord::Base

  belongs_to :system_channel

  validates_uniqueness_of :system_channel_id
  validates_presence_of :system_channel_id
end
