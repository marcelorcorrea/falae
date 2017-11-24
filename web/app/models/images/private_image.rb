class PrivateImage < Image
  has_one :item, as: :image

  def attachment_path
    "#{ENV['FALAE_IMAGES_PATH']}/private/img_:id.:extension"
  end

  def attachment_url
    "/users/#{item.user_id}/items/#{item.id}/image"
  end
end
