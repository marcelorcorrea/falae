class Pictogram < Image
  has_many :items, as: :image

  def attachment_path
    "#{ENV['FALAE_IMAGES_PATH']}/public/:id.:extension"
  end

  def attachment_url
    '/assets/:id.:extension'
  end

  def pictogram?
    true
  end

  def self.find_like_by_and_locale(params)
    query = [
      "#{params.keys.first} LIKE ? AND locale = ?",
      "#{params.values.first}%",
      params[:locale]
    ]
    Pictogram.where(query)
  end

  def generate_item
    name = image_basename
    item = Item.new name: name, speech: name, image: self
  end

  private

  def image_basename
    File.basename(image_file_name, File.extname(image_file_name)).gsub('_', ' ')
  end
end
