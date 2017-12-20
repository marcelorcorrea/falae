class RemoveDefaultAndImageFromItems < ActiveRecord::Migration[5.1]
  def change
    remove_column :items, :default
    remove_attachment :items, :image
  end
end
