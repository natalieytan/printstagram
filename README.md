## SET UP
1. Start new project without the default test-suite.

`rails new printstagram -T`


2. Install Gems:
```ruby
source 'https://rubygems.org'

gem 'rails', '~> 5.1.6'
gem 'stripe', '~> 3.13'
gem 'devise', '~> 4.4', '>= 4.4.3'
gem 'pundit', '~> 1.1'
gem 'shrine', '~> 2.10', '>= 2.10.1'
gem 'geocoder', '~> 1.4', '>= 1.4.7'
gem 'materialize-sass', '~> 0.100.2'
gem 'puma', '~> 3.7'
gem 'sass-rails', '~> 5.0'
gem 'uglifier', '>= 1.3.0'
gem 'coffee-rails', '~> 4.2'
gem 'turbolinks', '~> 5'
gem 'jbuilder', '~> 2.5'

group :development, :test do
  gem 'dotenv-rails', '~> 2.4'
  gem 'sqlite3'
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
end

group :test do
  gem 'rspec-rails', '~> 3.7', '>= 3.7.2'
  gem 'factory_bot', '~> 4.8', '>= 4.8.2'
  gem 'capybara', '~> 3.0', '>= 3.0.2'
end

group :development do
  gem 'web-console', '>= 3.3.0'
  gem 'listen', '>= 3.0.5', '< 3.2'
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
end

group :production do
  gem 'pg', '0.18.4'
end

gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]

```

3. Bundle install

`bundle install`

## Install 
### Rspec
`bin/rails g rspec:install`

### Devise
`bin/rails g devise:install`

### Pundit
`bin/rails g pundit:install`

##  Install Materialize & Set Up Template
Rename `app/assets/stylesheets/application.css` to `app/assets/stylesheets/application.scss` and import materialize styles:
```
# app/assets/stylesheets/application.scss
@import "materialize";
```

Require materialize javascript files
```
# app/assets/javascripts/application.js
//= require jquery
//= require turbolinks
//= require materialize-sprockets
```

First Commit!
`git add --all`

`git commit -m "First Commit."`