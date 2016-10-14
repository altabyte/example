class StockLocation < ActiveRecord::Base

  has_many :stock_location_users, :dependent => :destroy
  belongs_to :company
  accepts_nested_attributes_for :stock_location_users, :allow_destroy => true
  attr_encrypted :ftp_password, :key => 'FTP_Password', :attribute => 'ftp_password_encrypted'
  validates_presence_of :name
  validates_presence_of :reference

  validates_uniqueness_of :name, :scope => :company_id
  validates_uniqueness_of :reference, :scope => :company_id

  def check_location_for(user)
    slu = StockLocationUser.where(:stock_location_id => self).where(:user_id => user.id)
    if slu.present?
      self
    else
      false
    end
  end

end
