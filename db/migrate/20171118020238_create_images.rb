class CreateImages < ActiveRecord::Migration[5.1]
  def change
    create_table :images do |t|
      t.string :type
      t.attachment :image

      t.timestamps
    end
    add_index :images, :image_file_name
  end
end
