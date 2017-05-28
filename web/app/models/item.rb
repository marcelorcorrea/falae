class Item < ApplicationRecord
  has_one :item_user, dependent: :destroy
  has_one :user, through: :item_user
  has_many :item_page, dependent: :destroy
  has_many :pages, through: :item_page
  has_one :category_item, dependent: :destroy
  has_one :category, through: :category_item

  validates_associated :category
  validates :name, :speech, :img_src, presence: true

  after_save do
    if not self.user and not self.default
      self.update user: self.pages.first.spreadsheet.user
    end
  end

  def Item.defaults
    @default_items ||= Item.where default: true
  end
end
