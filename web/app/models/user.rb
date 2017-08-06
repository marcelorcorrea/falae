class User < ApplicationRecord
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i

  attr_accessor :activation_token, :reset_token

  has_one :role_user, dependent: :destroy
  has_one :role, through: :role_user
  has_many :spreadsheets, dependent: :destroy
  has_many :item_user, dependent: :destroy
  has_many :items, through: :item_user
  has_attached_file :photo, default_url: 'missing_photo.png',
    path: ':rails_root/app/data/images/user_:id/photo.:extension',
    url: '/users/:id/photo'

  before_create :create_activation_digest
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
  validates_attachment_content_type :photo, content_type: /\Aimage\/(jpe?g|png|gif)/

  has_secure_password

  def admin?
    false
  end

  # Returns hash digest of given string
  def User.digest(string)
    cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST :
                                                  BCrypt::Engine.cost
    BCrypt::Password.create(string, cost: cost)
  end

  # Returns random token
  def User.new_token
    SecureRandom.urlsafe_base64
  end

  # Returns true if given token matches digest
  def authentic_token?(attribute, token)
    digest = send("#{attribute}_digest")
    return false if digest.nil?
    BCrypt::Password.new(digest).is_password?(token)
  end

  # Activates user account
  def activate
    update_columns(activated: true, activated_at: Time.zone.now)
  end

  # Sends activation email
  def send_activation_email
    UserMailer.account_activation(self).deliver_now
  end

  # Sets the password reset attributes
  def create_reset_digest
    self.reset_token = User.new_token
    update_columns(reset_digest: User.digest(reset_token), reset_sent_at: Time.zone.now)
  end

  # Sends password reset email
  def send_password_reset_email
    UserMailer.password_reset(self).deliver_now
  end

  # Returns true if a password reset has expired.
  def password_reset_expired?
    self.reset_sent_at < 2.hours.ago
  end

  private
    # Creates and assigns activation token and digest
    def create_activation_digest
      self.activation_token  = User.new_token
      self.activation_digest = User.digest(activation_token)
    end
end

