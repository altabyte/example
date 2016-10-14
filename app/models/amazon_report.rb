class AmazonReport < ActiveRecord::Base
  attr_accessible :company_id, :document_id, :payload, :payload_datetime, :submission_datetime
  belongs_to :channel
end
