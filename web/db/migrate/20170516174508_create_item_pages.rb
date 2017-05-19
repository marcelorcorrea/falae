class CreateItemPages < ActiveRecord::Migration[5.1]
  def change
    create_table :item_pages do |t|
      t.references :item, foreign_key: true
      t.references :page, foreign_key: true

      t.timestamps
    end
  end
end
