class Item < ApplicationRecord
  has_one :item_user, dependent: :destroy
  has_one :user, through: :item_user
  has_many :item_pages, dependent: :destroy
  has_many :pages, through: :item_pages
  has_one :category_item, dependent: :destroy
  has_one :category, through: :category_item

  validates_associated :category
  validates :name, :speech, :img_src, presence: true

  after_save do
    if not self.user and self.pages.present?
      self.update user: self.pages.first.spreadsheet.user
    end
  end

  def Item.defaults
    @default_items ||= Item.where default: true
  end

  # def Item.swap(id1, id2)
  #   item_1, item_2 = Item.find [id1, id2]
  #   puts "#{item_1.id} #{item_1.name}"
  #   puts "#{item_2.id} #{item_2.name}"
  #   tmp = item_1
  #   item_1.attributes = item_2.attributes.except('id')
  #   puts "item 1: #{item_1.attributes}"
  #   item_2.attributes = tmp.attributes.except('id')
  #   puts "item 2: #{item_2.attributes}"
  #   # ActiveRecord::Base.transaction do
  #   #   item_1.save!
  #   #   item_2.save!
  #   # end
  # rescue => e
  #   puts e.message
  #   # nil
  # end

  def has?(user)
    user.items.include? self
  end

  def in_page?(page)
    self.pages.present? and self.pages.include?(page)
  end
end
