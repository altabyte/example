class Channel < ActiveRecord::Base


  belongs_to :system_channel
  has_many :orders
  has_many :customers
  has_many :channel_statuses, :dependent => :destroy
  has_many :channel_updates
  belongs_to :address, :dependent => :destroy, :foreign_key => :return_address_id
  belongs_to :company
  belongs_to :admin_user, :class_name => "User", :foreign_key => "admin_user_id"

  after_initialize :build_associations

  has_attached_file :logo, :styles => {:medium => "300x300>", :thumb => "100x100>"}, :default_url => "/images/:style/missing.png"

  attr_encrypted :password_1, :key => 'ChannelPassword_1', :attribute => 'password_1_encrypted'
  attr_encrypted :password_2, :key => 'ChannelPassword_2', :attribute => 'password_2_encrypted'
  attr_encrypted :password_3, :key => 'ChannelPassword_3', :attribute => 'password_3_encrypted'

  accepts_nested_attributes_for :channel_statuses, :allow_destroy => true
  accepts_nested_attributes_for :address, :allow_destroy => true
  validates_uniqueness_of :name, :scope => :company_id
  #validates_uniqueness_of :product_master, :scope => :company_id
  validates_presence_of :name
  validates_presence_of :system_channel_id

  mount_uploader :terms_pdf, TermsPdfUploader

  scope :by_company, lambda { |company_id|
                     where(['company_id NOT IN (?)', company_id]) if company_id.present?
                   }

  scope :for_company, lambda { |company_id|
                      where(['company_id = (?)', company_id]) if company_id.present?
                    }


  def channel_updated_at(info)
    channel_update = ChannelUpdate.find_by_channel_id_and_info(self.id, info)
    channel_update.present? ? channel_update.channel_updated_at : ""
  end

  def build_associations
    build_address if self.return_address_id.blank?
  end

  def channel_updated_now(info, datetime)
    channel_update = ChannelUpdate.find_or_initialize_by_channel_id_and_info(self.id, info)
    channel_update.channel_updated_at = datetime
    channel_update.save!
  end

  def address_block
    if self.use_company_address_flag == "Y"
      address_block = "#{self.company.name}"
      address_block += "\n#{self.company.address_1.to_s.upcase}" unless self.company.address_1.nil?
      address_block += "\n#{self.company.address_2.to_s.upcase}" unless self.company.address_2.nil?
      address_block += "\n#{self.company.town.to_s.upcase}" unless self.company.town.nil?
      address_block += "\n#{self.company.county.to_s.upcase}" unless self.company.county.nil?
      address_block += "\n#{self.company.post_code.to_s.upcase}" unless self.company.post_code.nil?
      address_block += "\n#{Country.find_country_by_alpha2(self.company.country).name}" unless self.company.country.nil?
      #if self.company.telephone.present?
      #address_block += "\n#{I18n.t('reports.address_block_telephone')}: #{self.telephone}"
      #  elsif self.customer.phone_number.present?
      #address_block += "\n#{I18n.t('reports.address_block_telephone')}: #{self.customer.phone_number}"
      #  end
    else
      address_block = "#{self.address.name}"
      address_block += "\n#{self.address.address_1.to_s.upcase}" unless self.address.address_1.nil?
      address_block += "\n#{self.address.address_2.to_s.upcase}" unless self.address.address_2.nil?
      address_block += "\n#{self.address.town.to_s.upcase}" unless self.address.town.nil?
      address_block += "\n#{self.address.county.to_s.upcase}" unless self.address.county.nil?
      address_block += "\n#{self.address.post_code.to_s.upcase}" unless self.address.post_code.nil?
      address_block += "\n#{Country.find_country_by_alpha2(self.address.country).name}" unless self.address.country.nil?
    end
    address_block
  end

  def custom_logging(message)
    unless Rails.env.test?
      path = "#{Rails.root}/log/channels"
      FileUtils.mkdir_p(path)
      log_path = File.open("#{path}/#{self.id}.log", 'a')
      log_path.sync = true
      @channel_log ||= CustomLogger.new(log_path, 'daily')
      @channel_log.info "#{message}"
    end
  end


end
