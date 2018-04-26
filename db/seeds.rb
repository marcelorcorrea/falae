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

CATEGORIES = [
  {
    base_ctgy_name: 'GREETINGS_SOCIAL_EXPRESSIONS',
    description: 'Cumprimentos e expressões sociais',
    locale: 'pt'
  },
  {
    base_ctgy_name: 'SUBJECT',
    description: 'Sujeitos',
    locale: 'pt'
  },
  {
    base_ctgy_name: 'VERB',
    description: 'Verbos',
    locale: 'pt'
  },
  {
    base_ctgy_name: 'NOUN',
    description: 'Substântivos',
    locale: 'pt'
  },
  {
    base_ctgy_name: 'ADJECTIVE',
    description: 'Adjetivos',
    locale: 'pt'
  },
  {
    base_ctgy_name: 'OTHER',
    description: 'Outros',
    locale: 'pt'
  },
  {
    base_ctgy_name: 'GREETINGS_SOCIAL_EXPRESSIONS',
    description: 'Greetings and social expressions',
    locale: 'en'
  },
  {
    base_ctgy_name: 'SUBJECT',
    description: 'Subjects',
    locale: 'en'
  },
  {
    base_ctgy_name: 'VERB',
    description: 'Verbs',
    locale: 'en'
  },
  {
    base_ctgy_name: 'NOUN',
    description: 'Nouns',
    locale: 'en'
  },
  {
    base_ctgy_name: 'ADJECTIVE',
    description: 'Adjectives',
    locale: 'en'
  },
  {
    base_ctgy_name: 'OTHER',
    description: 'Others',
    locale: 'en'
  }
]

BASE_CATEGORIES.each do |base_ctgy|
  BaseCategory.find_or_create_by!(base_ctgy)
end

CATEGORIES.each do |ctgy|
  base_ctgy = BaseCategory.find_by!(name: ctgy[:base_ctgy_name])
  attrs = ctgy.except(:base_ctgy_name)
  Category.create_with(base_category: base_ctgy).find_or_create_by!(attrs)
end
