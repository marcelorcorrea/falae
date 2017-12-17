# Load the Rails application.
require_relative 'application'

# Initialize the Rails application.
Rails.application.initialize!

# transform key to camel case for json responses
Jbuilder.key_format camelize: :lower

if Rails.env.production? && ENV['SENDGRID_APIKEY'].blank?
  raise 'SENDGRID_APIKEY is not set'
end

FALAE_IMAGES_PATH = ENV['FALAE_IMAGES_PATH']

if FALAE_IMAGES_PATH.blank? || ! Dir.exist?(FALAE_IMAGES_PATH)
  raise 'FALAE_IMAGES_PATH is not set properly'
end

Dir.mkdir "#{FALAE_IMAGES_PATH}/public" unless Dir.exist? "#{FALAE_IMAGES_PATH}/public"
Dir.mkdir "#{FALAE_IMAGES_PATH}/private" unless Dir.exist? "#{FALAE_IMAGES_PATH}/private"
