class ChannelStatus < ActiveRecord::Base

  belongs_to :channel
  has_many :orders, :through => :channel

  validates_uniqueness_of :status_name, :scope => [:channel_id]
  validates_presence_of :status_name

end
