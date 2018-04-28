module Features
  module SessionHelpers
    
    def login(email, password)
      fill_in "Email", with: email
      fill_in "Password", with: password
      click_button "Log in"
    end
    
  end
end