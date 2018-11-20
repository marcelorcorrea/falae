class DropRoleUsers < ActiveRecord::Migration[5.1]
  def change
    drop_table :role_users do |t|
      t.references :role, foreign_key: true
      t.references :user, foreign_key: true

      t.timestamps
    end
  end
end
