class AddLinkToToItemPage < ActiveRecord::Migration[5.1]
  def change
    add_column :item_pages, :link_to, :string
  end
end
