class Company < ActiveRecord::Base

  has_many :channels
  has_many :users

  has_many :company_logs
  has_many :stock_locations

  has_one :fedex_setting, :dependent => :destroy
  accepts_nested_attributes_for :fedex_setting

  has_attached_file :logo, :styles => {:medium => "300x300>", :thumb => "100x100>"}, :default_url => "/images/:style/missing.png"
  validates_attachment :logo,
                       :content_type => {:content_type => ["image/jpeg", "image/gif", "image/png"]}
  mount_uploader :terms_pdf, TermsPdfUploader

  validates_uniqueness_of :name
  validates_presence_of :name
  belongs_to :user

  after_create :build_associations

  def build_associations
    self.build_fedex_setting
  end

  def address_to_html
    [self.address_1, self.address_2, self.town, self.county,
     self.post_code, self.country_name].reject(&:blank?).join("<br />")
  end

  def country_name
    Country.find_country_by_alpha2(self.country).name unless self.country.blank? rescue ""
  end

end

