FROM ruby:3.2.2

LABEL Name=clinic_app Version=0.0.1

RUN DEBIAN_FRONTEND=noninteractive apt-get update -qq \
    && apt-get install -yq --no-install-recommends \
    build-essential \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /usr/src/app
COPY . /usr/src/app

RUN bundle install

RUN rails generate rspec:install

RUN bundle exec rails db:migrate
RUN RAILS_ENV=test bundle exec rails db:migrate

CMD ["bundle", "exec", "rspec --format documentation"]
