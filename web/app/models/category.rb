class Category < ApplicationRecord
  validates :name, :color, presence: true, uniqueness: true

  def Category.default
    Category.find_by name: 'OTHER'
  end
end
