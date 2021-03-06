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
gem 'image_processing', '~> 1.0'
gem 'mini_magick', '>= 4.3.5'
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
  gem 'selenium-webdriver', '~> 3.11'
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

# CREATE POSTS & IMAGEUPLOADER

## Write tests for the ImageUploader & Posts Model

`git branch posts`

`git checkout posts`

add to .gitignore

`public/uploads`

```ruby
# spec/uploaders/image_uploader_spec.rb
require 'rails_helper'

describe ImageUploader do
  context "with a valid image" do
    let(:post) { create(:post) }

    it "can create a post" do
      expect(post).to be_valid
    end
    it "generates image thumbnails" do
      expect(post.image.keys).to match_array [:original, :small, :medium, :large]
    end
  end
end
```

```ruby
# spec/models/post_spec.rb
require 'rails_helper'

describe Post, :type => :model do
  context 'validations' do
    it { should validate_presence_of :image_data }
    it { should validate_presence_of :caption }
    it { should belong_to :user }
    it { should validate_length_of(:caption).is_at_most(500) }
  end
end
```

## Configure Shrine
```ruby
#config/initializers/shrine.rb
require "shrine"
require "shrine/storage/file_system"

Shrine.storages = {
  cache: Shrine::Storage::FileSystem.new("public", prefix: "uploads/cache"), # temporary
  store: Shrine::Storage::FileSystem.new("public", prefix: "uploads/store"), # permanent
}

Shrine.plugin :activerecord
Shrine.plugin :cached_attachment_data # for forms
```


```ruby
require "image_processing/mini_magick"
 
class ImageUploader < Shrine
  plugin :processing
  plugin :activerecord, validations: true
  plugin :versions   # enable Shrine to handle a hash of files
  plugin :delete_raw # delete processed files after uploading
  plugin :validation_helpers
  plugin :determine_mime_type
  
  process(:store) do |io, context|

  Attacher.validate do
    validate_max_size 1.megabytes, message: 'is too large (max is 1 MB)'
    validate_mime_type_inclusion ['image/jpg', 'image/jpeg', 'image/png', 'image/gif']
    validate_extension_inclusion %w[jpg jpeg png gif]
  end
    original = io.download
    pipeline = ImageProcessing::MiniMagick.source(original)

    size_800 = pipeline.resize_to_limit!(800, 800)
    size_500 = pipeline.resize_to_limit!(500, 500)
    size_300 = pipeline.resize_to_limit!(300, 300)

    original.close!

    { original: io, large: size_800, medium: size_500, small: size_300 }
  end
end
```

## Create Post Model and Set Relationships
`bin/rails g model Post image_data:text caption:string user:references`

`bin/rails db:migrate`

Update post model to include imageuploader
```ruby
class Post < ApplicationRecord
  belongs_to :user
  include ImageUploader::Attachment.new(:image)
end

```

Update user model to iclude relationships with posts
```ruby
class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :lockable
  has_many :posts
end

```

run the tests `bundle exec rspec`

# CREATE PAGES (routes, controller, views) TO UPLOAD & VIEW POSTS

## Write Tests For Post CRUD

### Create
```ruby
require 'rails_helper.rb'

feature 'New posts can be created' do

  context 'when user is logged in' do
    before do
      create(:user)
      visit "/"
      click_link "Login"
      login "example@example.com", "password"
    end

    scenario 'with valid image and caption' do
      visit '/posts/new'
      attach_file('post_file', "spec/support/images/image.jpg")
      fill_in 'caption', with: 'this is my dummy image' 
      click_button 'Create Post'
      expect(page).to have_content('this is my dummy image')
      expect(page).to have_content("Post created!")
    end

    scenario 'but not with invalid filetype' do
      visit '/posts/new'
      attach_file('post_file', "spec/support/images/random.pdf")
      fill_in 'caption', with: 'woof' 
      click_button 'Create Post'
      expect(page).to have_content("errors prohibited this post from being saved")
      expect(page).to have_content("Unable to create post!")
      expect(page).not_to have_content("Post created!")
    end

    scenario 'but not with files larger than 1MB' do
      visit '/posts/new'
      attach_file('post_file', "spec/support/images/verylargefile.png")
      fill_in 'caption', with: 'woof' 
      click_button 'Create Post'
      expect(page).to have_content("Unable to create post!")
      expect(page).not_to have_content("Post created!")
      expect(page).to have_content("Image is too large")
    end
  end

end
```
### Read

### Update

## Destroy
```ruby
require 'rails_helper.rb'

feature 'Posts can be deleted' do

    scenario 'when user is logged and post belongs to user' do
      user = create(:user, email: "example@example.com", password: "password")
      post = create(:post, user: user)
      visit "/"
      click_link "Login"
      login "example@example.com", "password"
      visit "/posts/#{post.id}"
      click_link 'delete'
      expect(page).to have_content("Post was successfully destroyed.")
      expect(current_path).to eq(posts_path)
    end
    
end
```

## Create Routes & Write Controller And Views for Post Index & Create

updates routes
```ruby
  root 'posts#index'
.
  resources :posts
.
```

`rails g controller Posts`

```ruby
class PostsController < ApplicationController
  before_action :set_post, only: [:show, :edit, :update, :destroy]
  skip_before_action :authenticate_user!, only: [:index, :show]

  def index
    @posts = Post.all
  end

  def show
  end

  def new
    @post = Post.new
  end

  def edit
  end

  def create
    @post = Post.new(post_params)
    @post.user = current_user
    if @post.save
      flash[:notice] = "Post created!"
      redirect_to @post
    else
      flash.now[:alert] = "Unable to create post!"
      render 'new'
    end
  end

  def update
      edit_params =params.require(:post).permit(:caption)
      if @post.update(edit_params)
        flash[:notice] = "Post updated!"
        redirect_to @post
      else
        flash[:alert] = "Unable to update post!"
        render 'edit'
      end
  end


  def destroy
    @post.destroy
    redirect_to posts_url, notice: 'Post was successfully destroyed.'
  end
  private
    def set_post
      @post = Post.find(params[:id])
    end

    def post_params
      params.require(:post).permit(:image, :caption)
    end
end


```


### Index View
views/posts/index.html.erb
```html
<h2>Posts</h2>

<%= link_to 'New Post', new_post_path, class: "btn btn-primary btn-lg btn-block" %>

<div class="row">
  
    <% @posts.each do |post| %>
    <div class="col s12 m4">
    <%= render 'image_card', post: post, size: :medium, card_size: "card large" %>
    </div>
    <% end %>
    
    
</div>

```

### New View
views/posts/new.html.erb

```html
<h1>New Post</h1>

<%= render 'form', post: @post %>

<%= link_to 'Back', posts_path %>

```

### Post (Show) View
views/posts/show.html.erb

```html
  <%= render 'image_card', post: @post, size: :large, card_size: "card" %>
```

## Post Form Partial
views/posts/_form.html.erb
```
<%= form_with(model: post, local: true) do |form| %>
  <% if post.errors.any? %>
    <div id="error_explanation">
      <h2><%= pluralize(post.errors.count, "error") %> prohibited this post from being saved:</h2>

      <ul>
      <% post.errors.full_messages.each do |message| %>
        <li><%= message %></li>
      <% end %>
      </ul>
    </div>
  <% end %>
<div class="row">
    <div class="file-field input-field">
      <div class="waves-effect waves-light btn btn-block">
        <span>Upload photo <i class="material-icons">add_a_photo</i></span>
        
        <%= form.hidden_field :image, value: post.cached_image_data %>
        <%= form.file_field :image, accept: 'image/jpeg,image/jpg,image/gif,image/png', id: "post_file" %>
      </div>
      <div class="file-path-wrapper">
        <input class="file-path validate" type="text" placeholder="Upload a picture">
      </div>
    </div>

    
  <div class="field">
    <%= form.label :caption %>
    <%= form.text_area :caption, id: :caption %>
  </div>

  <div class="actions">
    <%= form.submit class: "waves-effect waves-light btn" %>
  </div>
<% end %>

<script type="text/javascript">
  $('#post_file').bind('change', function() {
    var size_in_megabytes = this.files[0].size/1024/1024;
    if (size_in_megabytes > 1) {
      alert('Maximum file size is 1MB. Please choose a smaller file.');
    }
  });
</script>
```

## Image Card Partial
views/posts/image_card.html.erb
```html

  <%= content_tag :div, class: card_size do %>
    <%= link_to post_path(post) do %>
    <div class="card-image">
        <%= image_tag post.image_url(size), class:"responsive-img" %>
    </div>
    <% end %>
    <div class="card-content">
          <p><%= post.caption %></p>
           <p class="grey-text "> <%= post.user.email %></p>
          <p class="grey-text ">Posted <%= time_ago_in_words(post.created_at) %> ago</p>
    </div>
 
    <div class="card-action">
     <%= link_to  edit_post_path(post), class: "btn-floating btn-large waves-effect waves-light" do %> <%= content_tag(:i , "edit", class:"tiny material-icons")%> <% end %> <%= link_to post, method: :delete, data: { confirm: 'Are you sure you want to delete this post?' }, class: "btn-floating btn-large waves-effect waves-light" do %><%= content_tag(:i , "delete", class:"tiny material-icons")%> <% end %>
    </div>


<% end %>
 
```