source 'https://rubygems.org'

gem 'rails', '3.2.11'

group :production do
  gem 'pg'
end

group :development, :test do
  gem 'sqlite3'
end
gem 'weather-underground'
gem 'slim'
gem 'eventbrite-client'
gem 'jquery_datepicker'
# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails',   '~> 3.2.3'
  gem 'coffee-rails', '~> 3.2.1'
  gem 'twitter-bootstrap-rails'
  gem 'less-rails'
  gem 'therubyracer', :platforms => :ruby

  gem 'uglifier', '>= 1.0.3'
end

group :test do
  gem "rspec-rails"
  gem "factory_girl_rails"
  gem "capybara"
  gem "guard-rspec"
  gem "spork", "> 0.9.0.rc"
end

gem 'jquery-rails'

