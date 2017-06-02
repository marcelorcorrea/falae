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
        post 'items/add_to_page', to: 'items#add_to_page'
      end
    end
    resources :items
    post 'items/add_to_user', to: 'items#add_to_user'
  end

  #post 'users/:id/items/add_to' => 'items#add_to', as: :add_to_my_items

  #resources :categories
end
