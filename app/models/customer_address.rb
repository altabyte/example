class CustomerAddress < ActiveRecord::Base

  belongs_to :customer

  validates_presence_of :address_1
  validates_presence_of :country

  geocoded_by :geocode_address
  after_validation :geocode, if: ->(obj) { obj.address_type == 'SHIPPING' }

  def address_block
    address_block = "#{self.get_name}"
    address_block += "\n#{self.company.to_s.upcase}" unless self.company.blank?
    address_block += "\n#{self.address_1.to_s.upcase}" unless self.address_1.blank?
    address_block += "\n#{self.address_2.to_s.upcase}" unless self.address_2.blank?
    address_block += "\n#{self.town.to_s.upcase}" unless self.town.blank?
    address_block += "\n#{self.county.to_s.upcase}" unless self.county.blank?
    address_block += "\n#{self.post_code.to_s.upcase}" unless self.post_code.blank?
    address_block += "\n#{Country.find_country_by_alpha2(self.country).name}" unless self.country.blank?
    if self.telephone.present?
      address_block += "\n#{I18n.t('reports.address_block_telephone')}: #{self.telephone}"
    elsif self.customer.phone_number.present?
      address_block += "\n#{I18n.t('reports.address_block_telephone')}: #{self.customer.phone_number}"
    end
    address_block
  end

  def to_html
    html = ""

    html += "#{self.get_name}<br />"
    html += "#{self.company.to_s.upcase}<br />" unless self.company.blank?
    html += "#{self.address_1.to_s.upcase}<br />" unless self.address_1.blank?
    html += "#{self.address_2.to_s.upcase}<br />" unless self.address_2.blank?
    html += "#{self.town.to_s.upcase}<br />" unless self.town.blank?
    html += "#{self.county.to_s.upcase}<br />" unless self.county.blank?
    html += "#{self.post_code.to_s.upcase}<br />" unless self.post_code.blank?
    html += "#{Country.find_country_by_alpha2(self.country).name}<br />" unless self.country.blank?
    if self.telephone.present?
      html += "\n#{I18n.t('reports.address_block_telephone')}: #{self.telephone}"
    elsif self.customer.phone_number.present?
      html += "\n#{I18n.t('reports.address_block_telephone')}: #{self.customer.phone_number}"
    end
    html
  end

  def geocode_address
    address_block = ''
    address_block += "#{self.company.to_s.upcase}" unless self.company.blank?
    address_block += ",#{self.address_1.to_s.upcase}" unless self.address_1.blank?
    address_block += ",#{self.address_2.to_s.upcase}" unless self.address_2.blank?
    address_block += ",#{self.town.to_s.upcase}" unless self.town.blank?
    address_block += ",#{self.county.to_s.upcase}" unless self.county.blank?
    address_block += ",#{self.post_code.to_s.upcase}" unless self.post_code.blank?
    address_block += ",#{Country.find_country_by_alpha2(self.country).name}" unless self.country.blank?
    address_block
  end

  def get_name
    name.blank? ? self.customer.full_name.upcase : self.name.upcase
  end

end
