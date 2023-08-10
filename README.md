# Falaê
![Falae App Logo](./app/assets/images/og_image_falae_widescreen.png?raw=true)

Falaê is an Android app developed by HP volunteers from Brazil R&D in partnership with the NGO Educandário – Centro de Reabilitação São João Batista. It is an Alternative Communication app, that allows people with speech and mobility impairments to communicate by using pictures that represent words (verbs, nouns, adjectives…).

Falaê consists of two parts: Android app and the web platform. The web page is used for user registering. Once registered, the user can customize their profile, as well as create and modify communication boards, pages and items. The Android app connects to the web platform in order to sincronize the user's data.

This repository consists in the web server, that is developed with Ruby on Rails.

The Android App repository can be found [here](https://github.com/marcelorcorrea/falae-android).

Feel free to fork or contribute this project.

[![Language Ruby on Rails](https://img.shields.io/badge/Language-Ruby_on_Rails-red.svg)](https://rubyonrails.org/)
[![License MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Download Android](https://img.shields.io/badge/Download-Google_Play_Store-yellow.svg)](https://play.google.com/store/apps/details?id=org.falaeapp.falae)
[![Slack channel](https://img.shields.io/badge/Chat-Slack-yellow.svg)](https://falaeapp.slack.com)

## Local setup

Falaê is currently using ruby 3.0.6. It is recommend to use *rbenv* or *rvm* and install the version.

#### Install rbenv

- Follow instructions available in https://github.com/rbenv/rbenv.

#### Install RVM

1. Find instructions on how to install GPC keys to verify installation package and ensure security at [https://rvm.io/rvm/install](https://rvm.io/rvm/install#install-gpg-keys).

2. Type the following command into your terminal to install stable version of *rvm*:
```
curl -sSL https://get.rvm.io | bash -s stable
```
3. Finally, type the following for *rvm* to detect dot files in the web folder. It will use the specified project ruby version or, it will warn if version is currently not installed. It also creates the gemset automatically.
```
cd .
```

#### Install ruby

Using rbenv

```
rbenv install 3.0.6
```

Using rvm

```
rvm install ruby-3.0.6
```

#### Set FALAE_IMAGES_PATH environment variable

You must set FALAE_IMAGES_PATH environment variable to point to a directory where pictograms and user's images will be stored in. This variable should not point to the app's public directory.
```
export FALAE_IMAGES_PATH=<dir-name>
```

#### Setup local database
```
rails db:setup
```

#### Install bundler gem at global gemset (optional)
```
rvm @global do gem install bundler
```

#### Running falae

Install gems:
```
bundle install
```

Run the application
```
rails server
```

For development purposes, there is a useful rails task to populate the database with some pictogram samples.
```
rails pictograms:download_samples
```

#### System dependencies

* ImageMagick
  * Depending on the OS, this library is installed by default. If not, you can find build and install instructions [here](https://imagemagick.org/script/index.php).

## Authors

* [Leandro Manica](https://github.com/leandrohmanica)
* [Marcelo Correa](https://github.com/marcelorcorrea)
* [Matheus Longaray](https://github.com/longaraymatheus)
* [Tais Bellini](https://github.com/taisbellini)

## License

MIT -- see [LICENSE](LICENSE)
