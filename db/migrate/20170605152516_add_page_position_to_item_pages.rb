class AddPagePositionToItemPages < ActiveRecord::Migration[5.1]
  def change
    add_column :item_pages, :position, :integer
  end
end
