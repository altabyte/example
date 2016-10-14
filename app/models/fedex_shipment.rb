class FedexShipment < ActiveRecord::Base
  attr_accessible :order_id, :label
  belongs_to :order
  has_one :channel, :through => :order
  has_one :company, :through => :channel
  has_attached_file :label

  validates_attachment_content_type :label,
                                    :content_type => ['application/pdf'],
                                    :message => "only pdf files are allowed"


  scope :for_company, lambda { |company_id|
                      joins(:company).
                          where(['companies.id = ?', company_id]) if company_id.present?
                    }
  scope :not_printed, lambda { where(:printed_flag => 0) }
end
