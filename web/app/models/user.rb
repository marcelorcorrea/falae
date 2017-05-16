class User < ApplicationRecord
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i

  has_one :role_user, dependent: :destroy
  has_one :role, through: :role_user
  has_many :spreadsheets

  before_validation { self.role ||= Role.default }
  before_save { self.email = email.downcase }

  validates_associated :role
  validates :name, :last_name, presence: true, length: { maximum: 50 }
  validates :email, presence: true, uniqueness: { case_sensitive: false },
            length: { maximum: 255 }, format: { with: VALID_EMAIL_REGEX }
  validates :password, :password_confirmation, presence: true,
            length: { minimum: 6 }

  has_secure_password
end
