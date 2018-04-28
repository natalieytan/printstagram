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

## INSTALL
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

##  CREATE USER MODEL USING DEVISE
1. Make and checkout to a new git branch

`git branch users`

`git checkout users`

2. Create and migrate user model using devise
`bin/rails g devise User`

`bin/rails db:migrate`

3. Set up mailer configuration locally
```
# config/environments/development.rb
config.action_mailer.default_url_options = { host: 'localhost', port: 3000 }
```

4. Generate my devise views (to allow customisation)

`$ rails generate devise:views`

## SET UP MATERIALIZE TEMPLATE + INTEGRATE DEVISE LOGIN

1. update application.scss
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

2. update application.html.erb 
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

4. Add button styles to devise forms
e.g. ` <%= f.submit "Change my password", class: "waves-effect waves-light btn" %>`

5. Redirect to the login page if the user was not logged in.

```
# app/controllers/application_controller.rb
before_action :authenticate_user!
```

6. Save, Commit, Checkout to Master & Merge
`git add .`

`git add --all`

`git commit -m "Added Users Model and updated Template"`