class PrivateImage < Image
  has_one :item, as: :image

  validates_presence_of :user

  def attachment_path
    "#{ENV['FALAE_IMAGES_PATH']}/private/user_#{user_id}/:id.:extension"
  end

  def attachment_url
    "/users/#{user_id}/items/#{item.id}/image"
  end

  def private?
    true
  end
end
