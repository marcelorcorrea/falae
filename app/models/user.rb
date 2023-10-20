class User < ApplicationRecord
  PHOTO_WIDTH = 400
  PHOTO_HEIGHT = 480
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  UNACTIVATED_TTL = 30

  attr_accessor :activation_token, :reset_token, :crop_x, :crop_y, :crop_w,
                :crop_h, :current_password

  has_many :spreadsheets, dependent: :destroy
  has_many :items, dependent: :destroy
  has_attached_file :photo,
                    default_url: 'missing_photo.png',
                    path: "#{FALAE_IMAGES_PATH}/private/user_:id/"\
                          'photo.:extension',
                    url: '/users/:id/photo',
                    styles: {
                      crop: {
                        resize_image: {
                          width: PHOTO_WIDTH,
                          height: PHOTO_HEIGHT
                        }
                      }
                    },
                    processors: [:cropper]

  before_save { self.email = email.downcase }
  before_create :create_activation_digest
  after_create {
    reprocess_photo if cropping?
    send_activation_email
  }
  after_update :reprocess_photo, if: :cropping?
  after_destroy { self.photo = nil }

  validates :name, :last_name, presence: true, length: { maximum: 50 }
  validates :email,
            presence: true,
            uniqueness: { case_sensitive: false },
            length: { maximum: 255 },
            format: { with: VALID_EMAIL_REGEX },
            confirmation: true
  validates :locale,
            presence: true,
            inclusion: { in: I18n.available_locales.map(&:to_s) }
  validates :password, presence: true, length: { minimum: 6 }, on: :create
  validates :password,
            presence: true,
            length: { minimum: 6 },
            on: :update_password,
            if: :update_password?
  validates_attachment_content_type :photo,
                                    content_type: %r{\Aimage\/(jpe?g|png|gif)\z}

  has_secure_password
  has_secure_token :auth_token

  def self.cleanup_unactivated
    User.where('created_at < :ttl', ttl: UNACTIVATED_TTL.days.ago)
      .where(activated: false).destroy_all
  end

  def self.digest(string)
    cost = if ActiveModel::SecurePassword.min_cost
             BCrypt::Engine::MIN_COST
           else
             BCrypt::Engine.cost
           end
    BCrypt::Password.create(string, cost: cost)
  end

  def self.new_token
    SecureRandom.urlsafe_base64
  end

  def self.with_unexpired_auth_token(token, period)
    where(auth_token: token).where('auth_token_created_at >= ?', period).first
  end

  # def admin?
  #   false
  # end

  def activate
    update(activated: true, activated_at: Time.zone.now)
  end

  def authentic_token?(attribute, token)
    digest = send("#{attribute}_digest")
    return false if digest.nil?
    BCrypt::Password.new(digest).is_password?(token)
  end

  def authenticate!(passwd, attribute, message = nil)
    authenticated = authenticate(passwd)
    errors.add(attribute, message) unless authenticated
    authenticated
  end

  def create_reset_digest
    self.reset_token = User.new_token
    update(reset_digest: User.digest(reset_token), reset_sent_at: Time.zone.now)
  end

  def cropping?
    crop_x.present? && crop_y.present? && crop_w.present? && crop_h.present?
  end

  def find_items_like_by(param)
    query = ["#{param.keys.first} LIKE ?", "#{param.values.first}%"]
    items.includes(:image).where(private: true).where(query)
  end

  def revalidate_token_access
    regenerate_auth_token
    touch(:auth_token_created_at)
  end

  def reprocess_photo
    photo.reprocess!
  end

  def send_activation_email
    UserMailer.account_activation(self).deliver_now
  end

  def send_password_reset_email
    UserMailer.password_reset(self).deliver_now
  end

  def password_reset_expired?
    reset_sent_at < 2.hours.ago
  end

  def update_password_with_context(password_attributes)
    with_transaction_returning_status do
      assign_attributes(password_attributes)
      save(context: :update_password)
    end
  end

  private

  def create_activation_digest
    self.activation_token  = User.new_token
    self.activation_digest = User.digest(activation_token)
  end

  def update_password?
    password_digest_changed? || password.blank?
  end
end
