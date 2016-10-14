class User < ActiveRecord::Base
  include CompanyOrNil

  belongs_to :role
  has_many :stock_location_users
  has_many :stock_locations, :through => :stock_location_users
  belongs_to :stock_location, :class_name => "StockLocation", :foreign_key => "current_location_id"

  belongs_to :company
  accepts_nested_attributes_for :stock_locations, :reject_if => lambda { |p| p.values.all?(&:blank?) }, :allow_destroy => true
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :timeoutable, :token_authenticatable, :validatable


  attr_accessible :email, :password, :password_confirmation, :remember_me
  attr_accessible :name, :email, :password, :password_confirmation, :remember_me
  attr_accessible :role_id, :stock_locations, :stock_location_ids
  attr_accessible :default_landing_page, :company_id
  cattr_accessor :current_user

  validates_presence_of :name
  validates_uniqueness_of :email, :case_sensitive => false, :scope => :company_id

  before_save :ensure_authentication_token

  def ensure_authentication_token
    if authentication_token.blank?
      self.authentication_token = generate_authentication_token
    end
  end

  scope :by_company, lambda { |company_id|
                     if company_id.present?
                       if current_user.company_id.blank?
                         where("company_id = ? or company_id is null", company_id)
                       else
                         where("company_id = ?", company_id)
                       end
                     end
                   }


  def check_role?(check_role)
    self.role.name==check_role.to_s
  end

  def get_user
    @current_user = current_user
  end

  def nice_roles
    self.roles.map { |v| v.name }.to_sentence
  end

  def set_current_location(location)
    self.current_location_id = location
    self.save!
  end

  def generate_authentication_token
    loop do
      token = Devise.friendly_token
      break token unless User.where(authentication_token: token).first
    end
  end

  def max_order_id
    if self.company_id.present?
      max_order_id = Order.where(:company_id => self.company_id).maximum(:id)
    else
      max_order_id = Order.maximum(:id)
    end

    max_order_id.blank? ? 0 : max_order_id

  end

  def self.is_super?
    current_user.company_id.blank? rescue false
  end

  def is_super?
    self.company_id.blank? rescue false
  end

  def self.available_roles
    if User.is_super?
      Role.all
    else
      Role.where('name != "SuperUser"')
    end
  end

end
