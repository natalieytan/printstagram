Rails.application.routes.draw do
  root 'posts#index'
  root "devise/registrations#edit"
  devise_for :users 
  get 'p/:id', to: 'posts#by_user'
  resources :posts
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
