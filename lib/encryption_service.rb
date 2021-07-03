class EncryptionService
  KEY = ActiveSupport::KeyGenerator.new(
      Rails.application.secrets.secret_key_base
    ).generate_key(
      Rails.application.secrets.secret_key_base,
      ActiveSupport::MessageEncryptor.key_len
    ).freeze

  private_constant :KEY

  delegate :encrypt_and_sign, :decrypt_and_verify, to: :encryptor

  def self.encrypt (value)
    new.encrypt_and_sign(value)
  end

  def self.decrypt(value)
    new.decrypt_and_verify(value)
  end

  private

  def encryptor
    ActiveSupport::MessageEncryptor.new(KEY)
  end
end
