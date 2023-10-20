class Pictogram < Image
  has_many :items, as: :image

  def self.find_like_by_and_locale(params)
    query = [
      "#{params.keys.first} LIKE ? AND locale = ?",
      "#{params.values.first}%",
      params[:locale]
    ]
    Pictogram.where(query)
  end

  def attachment_path
    "#{FALAE_IMAGES_PATH}/public/:id.:extension"
  end

  def attachment_url
    '/assets/:id.:extension'
  end

  def generate_item
    name = image_basename
    Item.new name: name, speech: name, image: self
  end

  def pictogram?
    true
  end

  private

  def image_basename
    File.basename(image_file_name, File.extname(image_file_name)).tr('_', ' ')
  end
end
