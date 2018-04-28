require 'rails_helper'

feature "User log in" do
  scenario "allows users with valid credentials to log in from the index" do
    create(:user)
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