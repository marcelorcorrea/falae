class DropRoles < ActiveRecord::Migration[5.1]
  def change
    remove_index :roles, column: :name, unique: true

    drop_table :roles do |t|
      t.string :name, null: false

      t.timestamps
    end
  end
end
