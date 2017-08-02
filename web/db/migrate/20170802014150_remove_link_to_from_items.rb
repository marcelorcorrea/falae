class RemoveLinkToFromItems < ActiveRecord::Migration[5.1]
  def change
    remove_column :items, :link_to, :string
  end
end
