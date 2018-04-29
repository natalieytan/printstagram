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