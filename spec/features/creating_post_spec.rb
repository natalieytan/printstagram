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