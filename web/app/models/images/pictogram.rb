class Pictogram < Image
  has_many :items, as: :image

  def attachment_path
    "#{ENV['FALAE_IMAGES_PATH']}/public/:id.:extension"
  end

  def attachment_url
    '/assets/:id.:extension'
  end

  def image_basename
    File.basename(image_file_name, File.extname(image_file_name)).gsub('_', ' ')
  end

  def generate_item
    name = image_basename
    item = Item.new name: name, speech: name, image: self
  end
end
