class CreateItems < ActiveRecord::Migration[5.1]
  def change
    create_table :items do |t|
      t.string :name, null: false
      t.string :img_src, null: false
      t.string :speech, null: false

      t.timestamps
    end
  end
end
