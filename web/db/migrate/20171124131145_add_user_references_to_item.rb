class AddUserReferencesToItem < ActiveRecord::Migration[5.1]
  def change
    add_reference :items, :user, foreign_key: true
  end
end
