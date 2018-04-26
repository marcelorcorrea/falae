# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

BASE_CATEGORIES = [
  { name: 'GREETINGS_SOCIAL_EXPRESSIONS', color: '#CC6699' },
  { name: 'SUBJECT', color: '#E6E600' },
  { name: 'VERB', color: '#009900' },
  { name: 'NOUN', color: '#FFA500' },
  { name: 'ADJECTIVE', color: '#0000FF' },
  { name: 'OTHER', color: '#FFFFFF' }
]

BASE_CATEGORIES.each do |base_ctgy|
  BaseCategory.find_or_create_by!(base_ctgy)
end
