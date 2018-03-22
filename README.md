# Falaê

Falaê is an Android app developed by HP volunteers from Brazil R&D in
partnership with the NGO Educandário – Centro de Reabilitação São João
Batista. It is an Alternative Communication app, that allows people with
speech and mobility impairments to communicate by using pictures that
represent words (verbs, nouns, adjectives…).

Falaê consists of two parts: Android app and the web platform. The web page is used for user registering. Once registered, the user can customize their profile, as well as create and modify communication boards, pages and items. The Android app connects to the web platform in order to sincronize the user's data.

This repository consists in the web server, that is developed with Ruby on Rails.

The Android App repository can be found [here](https://github.com/marcelorcorrea/falae-android)

Feel free to fork or contribute this project.

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

#### Database setup.
```
rails db:setup
```

#### Install bundler gem at global gemset.

```
rvm @global do gem install bundler
```

#### Running falae

Installing gems:

```
bundle install
```
Set FALAE_IMAGES_PATH environment variable, which should points to a directory where pictograms and users images will be stored. It should not set this variable to the app public directory.

```
export FALAE_IMAGES_PATH=<dir-name>
```

Running the application

```
rails server
```

There is a rails task to populate the database with some pictogram samples for development purposes.

```
rails pictograms:download_samples
```

#### System dependencies

* Image magick

## Authors

* [Leandro Manica](https://github.com/leandrohmanica)
* [Marcelo Correa](https://github.com/marcelorcorrea)
* [Matheus Longaray](https://github.com/longaraymatheus)
* [Tais Bellini](https://github.com/taisbellini)

## License

MIT -- see [LICENSE](LICENSE)
