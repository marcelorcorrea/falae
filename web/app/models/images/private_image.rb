class PrivateImage < Image
  has_one :item, as: :image
  has_one :user, through: :item

  def attachment_path
    "#{ENV['FALAE_IMAGES_PATH']}/private/img_:id.:extension"
  end

  def attachment_url
    "/users/#{user.id}/items/#{item.id}/image"
  end
end
