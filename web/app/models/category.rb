class Category < ApplicationRecord
  validates :name, :color, presence: true, uniqueness: true
end
