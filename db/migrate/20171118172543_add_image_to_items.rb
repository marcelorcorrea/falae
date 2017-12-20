class AddImageToItems < ActiveRecord::Migration[5.1]
  def change
    add_reference :items, :image, polymorphic: true, index: true
  end
end
