class BaseCategory < ApplicationRecord
  has_many :categories

  validates :name, :color, presence: true, uniqueness: true
end
