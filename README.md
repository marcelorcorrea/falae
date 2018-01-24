# Falaê

Falaê web server developed with Ruby on Rails.

Falaê is an Android app developed by HP volunteers from Brazil R&D in
partnership with the NGO Educandário – Centro de Reabilitação São João
Batista. It is an Alternative Communication app, that allows people with
speech and mobility impairments to communicate by using pictures that
represent words (verbs, nouns, adjectives…).
This web server is where the users can register, create boards and edit them.

The Android App repository can be found [here](https://github.com/marcelorcorrea/falae-android)

Feel free to Fork or contribute this project.

## Local setup

Falaê was developed using ruby 2.4.0. It is recommend to use *rvm* and install the version.

#### Install RVM

```
curl -sSL https://get.rvm.io | bash -s stable
```
Then
```
cd .
```
For *rvm* to detect dot files in the web folder. It will use the project ruby version
or warning it is not installed, also it will create the gemset.

#### Install ruby.

```
rvm install ruby-2.4.0
```

##### Database creation
```
rais db:setup
```

##### Database initialization
```
rails db:seed
```

##### System dependencies

* Image magick

## Authors

* [Leandro Manica](https://github.com/leandrohmanica)
* [Marcelo Correa](https://github.com/marcelorcorrea)
* [Matheus Longaray](https://github.com/longaraymatheus)
* [Tais Bellini](https://github.com/taisbellini)

## License

MIT -- see [LICENSE](LICENSE)


