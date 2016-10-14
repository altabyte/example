class Item < ActiveRecord::Base
  has_many :order_details
  has_many :item_inventories
  has_many :order_shipments

  validates_uniqueness_of :sku, :scope => :company_id
  validates_presence_of :sku, :company_id

  belongs_to :hs_code, :foreign_key => :harmonization_code, :class_name => 'hs_code'

  belongs_to :company

  scope :by_company, lambda { |company_id|
                     where(['company_id NOT IN (?)', company_id]) if company_id.present?
                   }

  def harmonization_display
    if self.harmonization_code.present?
      hs_code = HsCode.find_by_code(self.harmonization_code)
      if hs_code.present?
        self.harmonization_code + ':' + hs_code.description
      end

    end

  end
end
