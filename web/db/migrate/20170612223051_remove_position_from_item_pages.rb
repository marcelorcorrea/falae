class RemovePositionFromItemPages < ActiveRecord::Migration[5.1]
  def change
    remove_column :item_pages, :position
  end
end
