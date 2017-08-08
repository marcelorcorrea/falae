class Item < ApplicationRecord
  has_one :item_user, dependent: :destroy
  has_one :user, through: :item_user
  has_many :item_pages, dependent: :destroy
  has_many :pages, through: :item_pages
  has_one :category_item, dependent: :destroy
  has_one :category, through: :category_item
  has_attached_file :image, path: :attachment_path, url: :attachment_url

  validates :name, :speech, presence: true
  validates_associated :category
  validates_attachment_presence :image
  validates_attachment_content_type :image, content_type: /\Aimage\/(jpe?g|png|gif)\z/

  after_save do
    if not self.user and self.pages.present?
      self.update user: self.pages.first.spreadsheet.user
    end
  end

  before_destroy { self.image = nil }

  def Item.defaults
    @default_items ||= Item.where default: true
  end

  def has?(user)
    user.items.include? self
  end

  def in_page?(page)
    self.pages.present? and self.pages.include?(page)
  end

  def image_remote_url=(url)
    self.image = URI.parse url
    @image_remote_url = url
  end

  def attachment_path
    # self.user is nil here, but not for attachment_url... something related to paperclip?
    if self.default?
      ':rails_root/public/images/:id.:extension'
    else
      ":rails_root/app/data/images/user_#{self.item_user.user_id}/item_:id.:extension"
    end
  end

  def attachment_url
    self.default? ? '/images/:id.:extension' : "/users/#{self.user.id}/items/:id/image"
  end
end
