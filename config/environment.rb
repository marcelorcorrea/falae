# Load the Rails application.
require_relative "application"

# Initialize the Rails application.
Rails.application.initialize!

# transform key to camel case for json responses
Jbuilder.key_format camelize: :lower

FALAE_IMAGES_PATH = ENV.fetch('FALAE_IMAGES_PATH') {
  raise 'FALAE_IMAGES_PATH is not set' if Rails.env.production?
  File.join Rails.root, 'storage'
}

raise "FALAE_IMAGES_PATH (#{FALAE_IMAGES_PATH}) directory does not exist" unless Dir.exist?(FALAE_IMAGES_PATH)

Dir.mkdir "#{FALAE_IMAGES_PATH}/public" unless Dir.exist? "#{FALAE_IMAGES_PATH}/public"
Dir.mkdir "#{FALAE_IMAGES_PATH}/private" unless Dir.exist? "#{FALAE_IMAGES_PATH}/private"
