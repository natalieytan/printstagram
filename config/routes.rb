Rails.application.routes.draw do
  root 'static#index'
  root "devise/registrations#edit"
  devise_for :users
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
