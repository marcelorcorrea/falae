class Item < ApplicationRecord
  belongs_to :page

  validates :name, :speech, :img_src, presence: true
end
