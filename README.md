# Falaê

Falaê web server develop with Ruby on Rails.

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


