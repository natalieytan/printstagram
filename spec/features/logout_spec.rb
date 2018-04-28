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