class Role < ApplicationRecord
  has_many :role_users
  has_many :users, through: :role_users
  validates :name, presence: true, uniqueness: true

  def Role.default
    @default_role ||= Role.find_or_create_by name: :user
  end
end
