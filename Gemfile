source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '3.0.2'

gem 'rails', '~> 6.1.4', '>= 6.1.4.4'
gem 'puma', '~> 5.0'
gem 'sass-rails', '>= 6'
gem 'webpacker', '~> 5.0'
gem 'jbuilder', '~> 2.7'
gem 'devise'
gem 'devise-i18n'
gem 'rails-i18n', '~> 6.0.0'
gem 'font-awesome-rails'
gem 'rails-controller-testing'

group :development, :test do
  gem 'byebug'
  gem 'rspec-rails', '~> 5.0.0'
  gem 'factory_bot_rails'
  gem 'shoulda-matchers', '~> 5.0'
  gem 'capybara'
  gem 'launchy'
  gem 'sqlite3', '~> 1.4'
end

group :production do
  gem 'pg'
end

group :development do
  gem 'web-console', '>= 4.1.0'
  gem 'rack-mini-profiler', '~> 2.0'
end
