Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  root 'home#home'
  get '/home', to: 'home#home'
  get '/about', to: 'home#about'
  get '/contact', to: 'home#contact'
  get '/login', to: 'sessions#new'
  post '/login', to: 'sessions#create'
  delete '/logout', to: 'sessions#destroy'

  resources :items

  #resources :roles

  resources :users do
    resources :spreadsheets do
      resources :pages do
        resources :items
      end
    end
    resources :items
  end

  #resources :categories
end
