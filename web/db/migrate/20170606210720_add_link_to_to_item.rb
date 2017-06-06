class AddLinkToToItem < ActiveRecord::Migration[5.1]
  def change
    add_column :items, :link_to, :string
  end
end
