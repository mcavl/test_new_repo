# frozen_string_literal: true

source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '3.2.2'

# Bundle edge Rails instead: gem "rails", github: "rails/rails", branch: "main"
gem 'rails', '~> 7.1', '>= 7.1.2'

# The original asset pipeline for Rails [https://github.com/rails/sprockets-rails]
gem 'sprockets-rails'

# Use sqlite3 as the database for Active Record
gem 'sqlite3', '~> 1.4'

# Use the Puma web server [https://github.com/puma/puma]
gem 'puma', '~> 6.4'

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo', '~> 2.0', '>= 2.0.6'
gem 'tzinfo-data', platforms: %i[mingw mswin x64_mingw jruby]

group :development, :test do
  gem 'factory_bot_rails', '~> 6.2'
  gem 'rspec-rails', '~> 6.0', '>= 6.0.3'
end

group :development do
  gem 'annotate',           '~> 3.2', require: false
end

group :test do
  # Use system testing [https://guides.rubyonrails.org/testing.html#system-testing]
  gem 'rubocop', '~> 1.57', '>= 1.57.2', require: false
  gem 'shoulda-matchers',   '~> 5.3'
  gem 'simplecov',          '~> 0.22.0', require: false
  gem 'simplecov-html',     '~> 0.12.3', require: false
  gem 'timecop',            '~> 0.9.8'
end
