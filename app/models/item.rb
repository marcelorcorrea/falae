class Item < ApplicationRecord
  belongs_to :category
  belongs_to :image, polymorphic: true, validate: true
  belongs_to :user
  has_many :item_pages, dependent: :destroy
  has_many :pages, through: :item_pages

  validates :name, :speech, presence: true

  accepts_nested_attributes_for :image

  after_save do
    update user: pages.first.spreadsheet.user if user.blank? && pages.present?
  end

  after_update { image.reprocess_image if image.cropping? }
  after_destroy { image.destroy if image.private? }

  def build_image(params)
    if image
      image.update image: params[:image]
    else
      img = PrivateImage.create params
      img.reprocess_image if img.valid? && img.cropping?
      self.image = img
    end
  end

  def image?
    image.image&.present?
  end

  def image_attributes=(attributes)
    image_id = attributes[:id]
    if image_id.present?
      img = Image.find_by(id: image_id)
      update image: img
    end
    super
  end

  def in_page?(page)
    pages.present? && pages.include?(page)
  end
end
