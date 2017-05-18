class CreateItemUsers < ActiveRecord::Migration[5.1]
  def change
    create_table :item_users do |t|
      t.references :item, foreign_key: true
      t.references :user, foreign_key: true

      t.timestamps
    end
  end
end
