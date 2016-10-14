class CompanyPackagingType < ActiveRecord::Base
  attr_accessible :company_id, :packaging_type_id, :name, :width, :height, :length

  belongs_to :company
  belongs_to :packaging_type

  validates_presence_of :width, :height, :length, :if => Proc.new { |record| record.packaging_type.present? ? record.packaging_type.name == 'CUSTOM' : true }
  validates_numericality_of :width, :height, :length, :greater_than => 0, :allow_blank => true, :if => Proc.new { |record| record.packaging_type.present? ? record.packaging_type.name == 'CUSTOM' : true }


  validates_uniqueness_of :packaging_type_id, :scope => :company_id, :unless => Proc.new { |record| record.packaging_type.name == 'CUSTOM' }
  validates_uniqueness_of :name, :scope => :company_id
end
