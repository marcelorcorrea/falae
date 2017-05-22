Rails.application.routes.draw do
  root 'home#home'
  get '/home', to: 'home#home'
  get '/about', to: 'home#about'
  get '/contact', to: 'home#contact'
  get '/login', to: 'sessions#new'
  get '/register', to: 'sessions#register'

  resources :items
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  resources :roles

  resources :users do
    resources :spreadsheets do
      resources :pages
    end
  end

  resources :categories
end
