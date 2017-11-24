class Item < ApplicationRecord
  has_one :item_user, dependent: :destroy
  has_one :user, through: :item_user
  has_many :item_pages, dependent: :destroy
  has_many :pages, through: :item_pages
  has_one :category_item, dependent: :destroy
  has_one :category, through: :category_item
  belongs_to :image, polymorphic: true

  validates :name, :speech, presence: true
  validates_associated :category

  accepts_nested_attributes_for :image

  after_save do
    if not self.user and self.pages.present?
      self.update user: self.pages.first.spreadsheet.user
    end
  end

  def image_attributes=(attributes)
    image_id = attributes[:id]
    if image_id.present?
      img = Image.find_by id: image_id
      self.update_attribute :image, img
    end
    super
  end

  def build_image(params)
    if self.image
      self.image.update_attributes image: params[:image]
    else
      img = PrivateImage.create params
      self.update_attribute :image, img
    end
  end

  def image?
    self.image.image.present? if self.image
  end

  def in_page?(page)
    self.pages.present? and self.pages.include?(page)
  end
end
