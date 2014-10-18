source 'https://rubygems.org'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '4.1.5'
# Use postgresql as the database for Active Record

group :test, :development do
  gem 'annotate'
  gem 'rspec-rails'
  gem 'shoulda-matchers'
  gem 'factory_girl_rails'
  gem 'database_cleaner'
  # Use debugger
  # gem 'debugger', group: [:development, :test]
end

group :development do
  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'quiet_assets'
  gem 'rack-mini-profiler'
  gem 'brakeman', :require => false
  gem "rails-erd"
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  # Use Capistrano for deployment
  # gem 'capistrano-rails'
end

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  # Use SCSS for stylesheets
  gem 'sass-rails', '~> 4.0.3'
  # Use CoffeeScript for .js.coffee assets and views
  gem 'coffee-rails', '~> 4.0.0'
  # See https://github.com/sstephenson/execjs#readme for more supported runtimes
  # gem 'therubyracer',  platforms: :ruby
  gem 'therubyracer', platforms: :ruby
  # Use Uglifier as compressor for JavaScript assets
  gem 'uglifier', '>= 1.3.0'
  gem 'bootstrap-sass', '~> 2.3.1.0'
end

group :doc do
  # bundle exec rake doc:rails generates the API under doc/api.
  gem 'sdoc', '~> 0.4.0'
end

group :production do
  # Use unicorn as the app server
  gem 'unicorn'
  gem 'rails_12factor'
end

gem 'pg'

# Frontend stuff
# Use jquery as the JavaScript library
gem 'jquery-rails'
gem 'jquery-ui-rails'
# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
gem 'turbolinks'
#gem 'cocoon'
#gem 'rails3-jquery-autocomplete'
#gem 'select2-rails'
#gem 'kaminari'

# Uploads
#gem 'carrierwave'
#gem 'fog'
#gem 'unf'
#gem 'wkhtmltopdf-binary'
#gem 'wicked_pdf'
#gem 'roo'
#gem 'to_xls', '~> 1.0.0'

# Indexing
#gem 'sunspot_rails'
#gem 'sunspot_solr'
#gem 'progress_bar'

# Authentication
#gem 'devise'

#Monitoring
#gem 'newrelic_rpm'
#gem "bugsnag"

# Misc
#gem "paranoia"
#gem 'delayed_job_active_record'
#gem "bitbucket_rest_api"