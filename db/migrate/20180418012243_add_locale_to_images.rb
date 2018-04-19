class AddLocaleToImages < ActiveRecord::Migration[5.1]
  def change
    add_column :images, :locale, :string
    add_index :images, :locale

    Pictogram.update_all locale: I18n.default_locale
  end
end
