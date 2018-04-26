class ChangeCategory < ActiveRecord::Migration[5.1]
  def change
    add_column :categories, :locale, :string, default: I18n.default_locale
    add_reference :categories, :base_category, foreign_key: true

    reversible do |dir|
      dir.up do
        Category.all.each do |ctgy|
          base_ctgy = BaseCategory.find_by(name: ctgy.name)
          ctgy.update!(base_category: base_ctgy)
        end
      end
      dir.down do
        Category.all.each do |ctgy|
          base_ctgy = ctgy.base_category
          ctgy.update!(name: base_ctgy.name, color: base_ctgy.color)
        end
      end
    end

    remove_index :categories, :name
    remove_column :categories, :name, :string
    remove_column :categories, :color, :string
  end
end
