class RemoveImgSrcFromItems < ActiveRecord::Migration[5.1]
  def change
    remove_column :items, :img_src, :string
  end
end
