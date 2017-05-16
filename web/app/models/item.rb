class Item < ApplicationRecord
  belongs_to :page
  has_one :category_item
  has_one :category, through: :category_item

  validates_associated :category
  validates :name, :speech, :img_src, presence: true
end
