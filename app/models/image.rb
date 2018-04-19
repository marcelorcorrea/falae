class Image < ApplicationRecord
  IMAGE_WIDTH = 500
  IMAGE_HEIGHT = 500
  attr_accessor :crop_x, :crop_y, :crop_w, :crop_h

  scope :pictogram, -> { where(type: 'Pictogram') }
  scope :private_images, -> { where(type: 'PrivateImage') }
  belongs_to :user, optional: true

  has_attached_file :image, path: :attachment_path, url: :attachment_url,
    styles: {crop: {resize_image: {width: IMAGE_WIDTH, height: IMAGE_HEIGHT}}},
    processors: [:cropper]

  validates :locale, presence: true,
            inclusion: { in: I18n.available_locales.map(&:to_s) }

  validates_attachment_presence :image
  validates_attachment_content_type :image, content_type: %r{\Aimage\/(jpe?g|png|gif)\z}

  before_destroy { self.image = nil }

  def image_remote_url=(url)
    self.image = URI.parse url
    @image_remote_url = url
  end

  def attachment_path
    raise NotImplementedError, 'This is an abstract base method.'
  end

  def pictogram?
    false
  end

  def private?
    false
  end

  def cropping?
    crop_x.present? && crop_y.present? && crop_w.present? && crop_h.present?
  end

  def reprocess_image
    image.reprocess!
  end

end
