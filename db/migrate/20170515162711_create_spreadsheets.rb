class CreateSpreadsheets < ActiveRecord::Migration[5.1]
  def change
    create_table :spreadsheets do |t|
      t.string :name, null: false
      t.string :initial_page
      t.references :user, foreign_key: true

      t.timestamps
    end
  end
end
