class Item < ApplicationRecord
  belongs_to :user
  has_many :item_pages, dependent: :destroy
  has_many :pages, through: :item_pages
  belongs_to :category, validate: true
  belongs_to :image, polymorphic: true

  validates :name, :speech, presence: true
  validates_associated :category

  accepts_nested_attributes_for :image

  delegate :private?, to: :image

  after_save do
    if not user and pages.present?
      update user: pages.first.spreadsheet.user
    end
  end

  after_update do
    image.reprocess_image if image.cropping?
  end

  after_destroy do
    image.destroy if image.private?
  end

  def image_attributes=(attributes)
    image_id = attributes[:id]
    if image_id.present?
      img = Image.find_by id: image_id
      update_attribute :image, img
    end
    super
  end

  def build_image(params)
    if image
      image.update_attributes image: params[:image]
    else
      img = PrivateImage.create params
      update_attribute :image, img
    end
  end

  def image?
    image.image&.present?
  end

  def in_page?(page)
    pages.present? and pages.include?(page)
  end
end
