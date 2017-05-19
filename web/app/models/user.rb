class User < ApplicationRecord
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i

  has_one :role_user, dependent: :destroy
  has_one :role, through: :role_user
  has_many :spreadsheets, dependent: :destroy
  has_many :item_user, dependent: :destroy
  has_many :items, through: :item_user

  before_validation do
    if self.role.blank?
      self.role = Role.default
    end
  end
  before_save do
    self.email = email.downcase
    if self.spreadsheets.empty?
      self.spreadsheets << Spreadsheet.default
    end
  end
  before_destroy { self.items.each { |item| item.destroy unless item.default }  }

  validates_associated :role
  validates :name, :last_name, presence: true, length: { maximum: 50 }
  validates :email, presence: true, uniqueness: { case_sensitive: false },
            length: { maximum: 255 }, format: { with: VALID_EMAIL_REGEX }
  validates :password, :password_confirmation, presence: true,
            length: { minimum: 6 }

  has_secure_password

  def User.admin?
    false
  end
end
