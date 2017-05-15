class User < ApplicationRecord
  has_one :role_user
  has_one :role, through: :role_user
  has_secure_password
end
