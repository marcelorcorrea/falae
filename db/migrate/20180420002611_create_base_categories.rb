class CreateBaseCategories < ActiveRecord::Migration[5.1]
  BASE_CATEGORIES = [
    { name: 'GREETINGS_SOCIAL_EXPRESSIONS', color: '#CC6699' },
    { name: 'SUBJECT', color: '#E6E600' },
    { name: 'VERB', color: '#009900' },
    { name: 'NOUN', color: '#FFA500' },
    { name: 'ADJECTIVE', color: '#0000FF' },
    { name: 'OTHER', color: '#FFFFFF' }
  ]

  def change
    create_table :base_categories do |t|
      t.string :name, null: false
      t.string :color, null: false

      t.timestamps
    end

    reversible do |dir|
      dir.up do
        BASE_CATEGORIES.each do |base_ctgy|
          BaseCategory.create!(base_ctgy)
        end
      end
    end
  end
end
