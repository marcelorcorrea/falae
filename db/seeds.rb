# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

Category.destroy_all
social_ctgy = Category.create! name: 'GREETINGS_SOCIAL_EXPRESSIONS', color: '#CC6699',
  description: 'Cumprimentos e expressões sociais'
subject_ctgy = Category.create! name: 'SUBJECT', color: '#E6E600', description: 'Sujeitos'
verbs_ctgy = Category.create! name: 'VERB', color: '#009900', description: 'Verbos'
nouns_ctgy = Category.create! name: 'NOUN', color: '#FFA500', description: 'Substântivos'
adjetives_ctgy = Category.create! name: 'ADJECTIVE', color: '#0000FF', description: 'Adjetivos'
Category.create! name: 'OTHER', color: '#FFFFFF', description: 'Outros'
