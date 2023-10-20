# Load the Rails application.
require_relative "application"

FALAE_IMAGES_PATH = ENV.fetch('FALAE_IMAGES_PATH') do
  raise 'FALAE_IMAGES_PATH environment variable is not set' if Rails.env.production?
  File.join Rails.root, 'storage'
end
FALAE_PUBLIC_IMAGES_PATH = "#{FALAE_IMAGES_PATH}/public"
FALAE_PRIVATE_IMAGES_PATH = "#{FALAE_IMAGES_PATH}/private"

# Initialize the Rails application.
Rails.application.initialize!

# transform key to camel case for json responses
Jbuilder.key_format camelize: :lower

raise "FALAE_IMAGES_PATH (#{FALAE_IMAGES_PATH}) directory does not exist" unless Dir.exist?(FALAE_IMAGES_PATH)

Dir.mkdir FALAE_PUBLIC_IMAGES_PATH unless Dir.exist? FALAE_PUBLIC_IMAGES_PATH
Dir.mkdir FALAE_PRIVATE_IMAGES_PATH unless Dir.exist? FALAE_PRIVATE_IMAGES_PATH
