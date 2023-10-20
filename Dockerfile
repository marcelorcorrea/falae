FROM ruby:3.0.6

RUN apt-get update -qq && apt-get install -y \
    build-essential \
    libpq-dev \
    nodejs \
    netcat \
    default-libmysqlclient-dev 

RUN gem install bundler

WORKDIR /app

RUN mkdir -p /images

COPY Gemfile Gemfile.lock ./

RUN bundle check || bundle install

COPY package.json ./

COPY . ./

RUN chmod +x entrypoint.sh

CMD [ "sh", "./entrypoint.sh" ]