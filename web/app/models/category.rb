class Category < ApplicationRecord
  has_many :items
  validates :name, :color, presence: true, uniqueness: true

  def Category.default
    @default_ctgy ||= Category.find_by name: 'OTHER'
  end
end
