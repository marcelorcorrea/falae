class AddDefaultFieldToItem < ActiveRecord::Migration[5.1]
  def change
    add_column :items, :default, :boolean, default: false
  end
end
