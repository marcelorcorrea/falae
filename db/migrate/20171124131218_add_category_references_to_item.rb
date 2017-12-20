class AddCategoryReferencesToItem < ActiveRecord::Migration[5.1]
  def change
    add_reference :items, :category, foreign_key: true
  end
end
