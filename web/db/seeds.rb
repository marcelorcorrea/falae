# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

Category.destroy_all
social_ctgy = Category.create! name: 'social', color: '#FC9A9C' #pink
person_ctgy = Category.create! name: 'person', color: '#FCFE04' #yellow
verbs_ctgy = Category.create! name: 'verbs', color: '#34CE34' #green
nouns_ctgy = Category.create! name: 'nouns', color: '#FC9A04' #orange
adjetives_ctgy = Category.create! name: 'adjetives', color: '#049AFC' #blue


Item.destroy_all
Item.create! [
  { name: 'oi', speech: 'oi', img_src: 'http://www.arasaac.org/repositorio/thumbs/10/200/6/6522.png',
    category: social_ctgy, default: true },
  { name: 'tchau', speech: 'tchau', img_src: 'http://www.arasaac.org/repositorio/thumbs/10/200/6/6028.png',
    category: social_ctgy, default: true },
  { name: 'obrigado', speech: 'obrigado', img_src: 'http://www.arasaac.org/repositorio/thumbs/10/200/8/8129.png',
    category: social_ctgy, default: true },
  { name: 'eu', speech: 'eu', img_src: 'http://www.arasaac.org/repositorio/thumbs/10/200/6/6632.png',
    category: person_ctgy, default: true },
  { name: 'você', speech: 'você', img_src: 'http://www.arasaac.org/repositorio/thumbs/10/200/6/6625.png',
    category: person_ctgy, default: true },
  { name: 'nós', speech: 'nós', img_src: 'http://www.arasaac.org/repositorio/thumbs/10/200/7/7186.png',
    category: person_ctgy, default: true },
  { name: 'querer', speech: 'querer', img_src: 'http://www.arasaac.org/repositorio/thumbs/10/200/3/31141.png',
    category: verbs_ctgy, default: true },
  { name: 'comer', speech: 'comer', img_src: 'http://www.arasaac.org/repositorio/thumbs/10/200/2/28413.png',
    category: verbs_ctgy, default: true },
  { name: 'beber', speech: 'beber', img_src: 'http://www.arasaac.org/repositorio/thumbs/10/200/6/6061.png',
    category: verbs_ctgy, default: true },
  { name: 'fruta', speech: 'fruta', img_src: 'http://www.arasaac.org/repositorio/thumbs/10/200/4/4653.png',
    category: nouns_ctgy, default: true },
  { name: 'bolo', speech: 'bolo', img_src: 'http://www.arasaac.org/repositorio/thumbs/10/200/8/8042.png',
    category: nouns_ctgy, default: true },
  { name: 'sorvete', speech: 'sorvete', img_src: 'http://www.arasaac.org/repositorio/thumbs/10/200/1/11382.png',
    category: nouns_ctgy, default: true },
  { name: 'água', speech: 'água', img_src: 'http://www.arasaac.org/repositorio/thumbs/10/200/2/2248.png',
    category: nouns_ctgy, default: true },
  { name: 'leite', speech: 'leite', img_src: 'http://www.arasaac.org/repositorio/thumbs/10/200/2/2445.png',
    category: nouns_ctgy, default: true },
  { name: 'suco', speech: 'suco', img_src: 'http://www.arasaac.org/repositorio/thumbs/10/200/1/11463.png',
    category: nouns_ctgy, default: true },
  { name: 'quente', speech: 'quente', img_src: 'http://www.arasaac.org/repositorio/thumbs/10/200/2/26716.png',
    category: adjetives_ctgy, default: true },
  { name: 'frio', speech: 'frio', img_src: 'http://www.arasaac.org/repositorio/thumbs/10/200/2/26865.png',
    category: adjetives_ctgy, default: true },
  { name: 'gostoso', speech: 'gostoso', img_src: 'http://www.arasaac.org/repositorio/thumbs/10/200/7/7124.png',
    category: adjetives_ctgy, default: true }
]
