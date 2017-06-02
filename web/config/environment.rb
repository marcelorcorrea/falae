# Load the Rails application.
require_relative 'application'

# Initialize the Rails application.
Rails.application.initialize!

# transform key to camel case for json responses
Jbuilder.key_format camelize: :lower