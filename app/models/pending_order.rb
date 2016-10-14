class PendingOrder < ActiveRecord::Base
  belongs_to :channel
  attr_accessible :company_id, :order_payload, :reason_pending, :channel_id
end
