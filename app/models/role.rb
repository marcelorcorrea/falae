class Role < ApplicationRecord
  DEFAULT_ROLE_NAME = 'user'
  # TODO: we cannot delete role if there is an associated user
  has_many :role_users, dependent: :destroy
  has_many :users, through: :role_users
  validates :name, presence: true, uniqueness: true

  def self.default
    @default ||= Role.find_or_create_by name: DEFAULT_ROLE_NAME
  end
end
