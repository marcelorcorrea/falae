class AddPrivateToItems < ActiveRecord::Migration[5.1]
  def change
    add_column :items, :private, :boolean, default: true
    Item.joins('INNER JOIN images ON items.image_id = images.id AND images.type = "Pictogram"')
      .update_all private: false
    Item.joins('INNER JOIN images ON items.image_id = images.id AND images.type = "PrivateImage"')
      .update_all private: true
  end
end
