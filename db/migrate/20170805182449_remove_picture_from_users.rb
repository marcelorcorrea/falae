class RemovePictureFromUsers < ActiveRecord::Migration[5.1]
  def change
    remove_column :users, :picture, :string
  end
end
