# INTRODUCTION
[https://printstagram.herokuapp.com/](https://printstagram.herokuapp.com/)

Hi, I am Nat. I am trying to create an instagram clone, while learning how to write RSpec for rails.

This is my process:

# SET UP
## Project & Gems
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
gem 'jquery-rails'
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
  gem "factory_bot_rails", "~> 4.0"
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
end

group :test do
  gem 'shoulda-matchers', '~> 3.1', '>= 3.1.2'
  gem 'rspec-rails', '~> 3.7', '>= 3.7.2'
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

## INSTALL & UPDATE RAILS_HELPER
### Rspec
`bin/rails g rspec:install`

### Devise
`bin/rails g devise:install`

### Pundit
`bin/rails g pundit:install`

Add Shoulda Matchers to Rails Helper
```
#rails_helper.rb (within the Rspec.configure block)
  Shoulda::Matchers.configure do |config|
    config.integrate do |with|
      with.test_framework :rspec
      with.library :rails
    end
```

Create `spec/support/factory_bot.rb`

```ruby
# spec/support/factory_bot.rb
RSpec.configure do |config|
    config.include FactoryBot::Syntax::Methods
end
```

Uncomment this line:

```ruby
# spec/rails_helper.rb
 Dir[Rails.root.join('spec/support/**/*.rb')].each { |f| require f }
```
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

#  CREATE USER MODEL USING DEVISE

Write the Rspec Tests for a the User Model
```ruby
# spec/models/user_spec.rb
require 'rails_helper'

describe User, :type => :model do
  context 'validations' do
    it { should validate_presence_of :email }
    it { should validate_presence_of :password }
    it { should validate_confirmation_of :password }
    it { should validate_uniqueness_of(:email).case_insensitive }
  end
end
```

Run the tests: `bundle exec rspec spec/models`

4 failures


1. Make and checkout to a new git branch

`git branch users`

`git checkout users`

2. Create and migrate user model using devise
`bin/rails g devise User`

`bin/rails db:migrate`


Run the tests again: `bundle exec rspec spec/models`

4 examples, 0 failures

3. Set up mailer configuration locally
```
# config/environments/development.rb
config.action_mailer.default_url_options = { host: 'localhost', port: 3000 }
```
```
# config/environments/test.rb
config.action_mailer.default_url_options = { :host => 'localhost' }
```


## Set up materialize template & integrate login into template

### Write the feature specs
```ruby
#spec/support/features/session_helpers.rb
module Features
  module SessionHelpers
    
    def login(email, password)
      fill_in "Email", with: email
      fill_in "Password", with: password
      click_button "Log in"
    end
    
  end
end
```

```ruby
#spec/support/features.rb
RSpec.configure do |config|
  config.include Features::SessionHelpers, type: :feature
end
```

```ruby
#spec/features/login_spec.rb
require 'rails_helper'

feature "User log in" do
  before do
    create(:user)
  end
  scenario "allows users with valid credentials to log in from the index" do
    visit "/"
    click_link "Login"
    expect(current_path).to eq(new_user_session_path)
    login "example@example.com", "password"
    expect(current_path).to eq "/"
    expect(page).to have_content "Signed in successfully"
    expect(page).to have_content "example@example.com"
  end

  scenario "fails if user has invalid credentials" do
    visit new_user_session_path
    login "e@example.tld", "test-password"
    expect(current_path).to eq(new_user_session_path)
    expect(page).not_to have_content "Signed in successfully"
    expect(page).to have_content "Invalid Email or password."
  end

  scenario "locks an account after 10 failed attempts" do
    email = "fake@example.com"
    create(:user, email: email, password: "somepassword")
    visit new_user_session_path
    (1..8).each do |attempt_num|
      login email, "wrong-password #{attempt_num}"
      expect(page).to have_content "Invalid Email or password."
    end
    login email, "wrong-password 9"
    expect(page).to have_content "You have one more attempt before your account is locked"
    login email, "wrong-password 10"
    expect(page).to have_content "Your account is locked."
  end
end
```

```ruby
#spec/features/user_registers_spec.rb
require 'rails_helper'

feature "User registers" do

  scenario "with valid details" do
    visit "/"
    first(:link, "Sign up").click
    expect(current_path).to eq(new_user_registration_path)
    fill_in "Email", with: "tester@example.tld"
    fill_in "Password", with: "test-password"
    fill_in "Password confirmation", with: "test-password"
    click_button "Sign up"
    expect(current_path).to eq "/"
  end

  context "with invalid details" do
    before do
      visit new_user_registration_path
    end
    scenario "blank fields" do
      expect_fields_to_be_blank
      click_button "Sign up"
      expect(page).to have_content "Email can't be blank",
        "Password can't be blank"
    end

    scenario "incorrect password confirmation" do
      fill_in "Email", with: "tester@example.tld"
      fill_in "Password", with: "test-password"
      fill_in "Password confirmation", with: "not-test-password"
      click_button "Sign up"
      expect(page).to have_content "Password confirmation doesn't match Password"
    end

    scenario "already registered email" do
      create(:user, email: "dave@example.tld")
      fill_in "Email", with: "dave@example.tld"
      fill_in "Password", with: "test-password"
      fill_in "Password confirmation", with: "test-password"
      click_button "Sign up"
      expect(page).to have_content "Email has already been taken"
    end

    scenario "invalid email" do
      fill_in "Email", with: "invalid-email-for-testing"
      fill_in "Password", with: "test-password"
      fill_in "Password confirmation", with: "test-password"
      click_button "Sign up"
      expect(page).to have_content "Email is invalid"
    end

    scenario "too short password" do
      min_password_length = 6
      too_short_password = "p" * (min_password_length - 1)
      fill_in "Email", with: "someone@example.tld"
      fill_in "Password", with: too_short_password
      fill_in "Password confirmation", with: too_short_password
      click_button "Sign up"
      expect(page).to have_content "Password is too short (minimum is #{min_password_length} characters)"
    end

  end

  private

  def expect_fields_to_be_blank
    expect(page).to have_field("Email", with: "", type: "email")
    # These password fields don't have value attributes in the generated HTML,
    # so with: syntax doesn't work.
    expect(find_field("Password", type: "password").value).to be_nil
    expect(find_field("Password confirmation", type: "password").value).to be_nil
  end

end
```

```ruby
#spec/features/logout_spec.rbs
require 'rails_helper'

feature "User can log out" do
  context "after signing in" do
    before do
      visit new_user_session_path
      user = create(:user)
      login("example@example.com", "password")
    end

    scenario "from index" do 
      visit "/"
      click_link "Logout"
      expect(page).to have_content "Signed out successfully."
      expect(page).not_to have_content "Logout"
      expect(page).to have_content "Login"
    end
  
  end

end
```

1. Create `static` controller and `index` action

`rails g controller Static index`

2. Set root path to static#index
```
#config/routes.rb
Rails.application.routes.draw do
  root 'static#index'
  root "devise/registrations#edit"
end

```

3. Generate my devise views (to allow customisation)

`$ rails generate devise:views`

4. update application.scss
```
@import "materialize";

body {
    display: flex;
    min-height: 100vh;
    flex-direction: column;
}
main {
    flex: 1 0 auto;
}
```

5. update application.html.erb 
```
# application.html.erb 
  <body>
   <nav>
    <div class="nav-wrapper teal">
      <a href="#" class="brand-logo">Printstagram</a>
     <ul id="nav-mobile" class="right hide-on-med-and-down">
        <li><a href="sass.html">Sass</a></li>
        <li><a href="badges.html">Components</a></li>
        <li><a href="collapsible.html">JavaScript</a></li>
      </ul>
    </div>
  </nav>
  

  <main>
    <div class="container">
      <div class="section">
      <%= yield %>
      </div>
    </div>
  </main>

   <footer class="page-footer teal">
          <div class="container">
            <div class="row">
              <div class="col l6 s12">
                <h5 class="white-text">Footer Content</h5>
                <p class="grey-text text-lighten-4">You can use rows and columns here to organize your footer content.</p>
              </div>
              <div class="col l4 offset-l2 s12">
                <h5 class="white-text">Links</h5>
                <ul>
                  <li><a class="grey-text text-lighten-3" href="#!">Link 1</a></li>
                  <li><a class="grey-text text-lighten-3" href="#!">Link 2</a></li>
                  <li><a class="grey-text text-lighten-3" href="#!">Link 3</a></li>
                  <li><a class="grey-text text-lighten-3" href="#!">Link 4</a></li>
                </ul>
              </div>
            </div>
          </div>
          <div class="footer-copyright">
            <div class="container">
            © 2014 Copyright Text
            <a class="grey-text text-lighten-4 right" href="#!">More Links</a>
            </div>
          </div>
        </footer>

  </body>
</html>

```

3. Update  the template
- Navbar to include login
- Include alert / notices within template
```
# application.html.erb 

   <nav>
    <div class="nav-wrapper teal">
      <a href="#" class="brand-logo">Printstagram</a>
     <ul id="nav-mobile" class="right hide-on-med-and-down">

<% if user_signed_in? %>
  <li>Logged in as <strong><%= current_user.email %></strong>.</li>
  <li><%= link_to 'Edit profile', edit_user_registration_path %></li>
  <li><%= link_to "Logout", destroy_user_session_path, method: :delete  %></li>
<% else %>
  <li><%= link_to "Sign up", new_user_registration_path  %></li>
  <li><%= link_to "Login", new_user_session_path  %></li>
<% end %>
      </ul>
    </div>
  </nav>

  <% if notice %>
  <p class="card-panel green lighten-4 green-text text-darken-4"><%= notice %></p>
<% end %>
<% if alert %>
  <p class="card-panel red lighten-4 red-text text-darken-4"><%= alert %></p>
<% end %>

```

6. Add button styles to devise forms
e.g. ` <%= f.submit "Change my password", class: "waves-effect waves-light btn" %>`

7. Redirect to the login page if the user was not logged in.

```
# app/controllers/application_controller.rb
before_action :authenticate_user!
```

8. Configure devise to have lockable feature
`rails g migration add_lockable_to_devise`

```ruby
#migration file
class AddLockableToDevise < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :failed_attempts, :integer, default: 0, null: false # Only if lock strategy is :failed_attempts
    add_column :users, :unlock_token, :string # Only if unlock strategy is :email or :both
    add_column :users, :locked_at, :datetime
    add_index :users, :unlock_token, unique: true
  end
end
```

`rails db:migrate`

update user model
```ruby
class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :lockable
end

```

Update config/initializers/devise.rb
```ruby
  config.lock_strategy = :failed_attempts
  config.unlock_keys = [:email]
  config.unlock_strategy = :both
  config.maximum_attempts = 10
  config.unlock_in = 1.hour
  config.last_attempt_warning = true
  config.reset_password_within = 6.hours
```
9.  Save, Commit, Checkout to Master & Merge
`git add .`

`git add --all`

`git commit -m "Added Users Model and updated Template"`

`git checkout master`

`git merge users`

# SET UP HEROKU WITH SENDGRID

`heroku create`

Update config/environments/development.rb
```ruby
  config.action_mailer.raise_delivery_errors = true
  config.action_mailer.delivery_method = :smtp
  host = 'prinstagram.herokuapp.com'
  config.action_mailer.default_url_options = { host: host }
  ActionMailer::Base.smtp_settings = {
    :address        => 'smtp.sendgrid.net',
    :port           => '587',
    :authentication => :plain,
    :user_name      => ENV['SENDGRID_USERNAME'],
    :password       => ENV['SENDGRID_PASSWORD'],
    :domain         => 'heroku.com',
    :enable_starttls_auto => true
  }

```

`git add .`

`git commit -m "Update action_mailer to sendgrid for heroku"`

`git push heroku master`

`heroku run rails db:migrate`

`heroku addons:create sendgrid:starter`