Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  root 'home#home'
  get '/home', to: 'home#home'
  get '/about', to: 'home#about'
  get '/contact', to: 'home#contact'
  get '/login', to: 'sessions#new'
  post '/login', to: 'sessions#create'
  delete '/logout', to: 'sessions#destroy'

  #resources :roles

  resources :users do
    resources :spreadsheets do
      resources :pages do
        resources :items do
          get 'image'
        end
        post 'items/add_to_page', to: 'items#add_to_page'
      end
      get 'pages/:id/add_item', to: 'pages#add_item', as: :page_add_item
      get 'pages/:id/search_item', to: 'pages#search_item', as: :page_search_item
      post 'pages/:id/add_to_page', to: 'pages#add_to_page', as: :add_to_page
      get 'pages/:id/edit_item', to: 'pages#edit_item', as: :page_edit_item
      put 'pages/:id/update_item', to: 'pages#update_item', as: :page_update_item
      delete 'pages/:id/remove_item', to: 'pages#remove_item', as: :page_remove_item
      put 'pages/:id/swap_items', to: 'pages#swap_items', as: :page_swap_items
    end
    resources :items do
      get 'image'
    end
    post 'items/add_to_user', to: 'items#add_to_user'
    get 'photo'
  end

  resources :account_activations, only: [:edit]
  resources :password_resets,     only: [:new, :create, :edit, :update]

  #post 'users/:id/items/add_to' => 'items#add_to', as: :add_to_my_items

  #resources :categories
end
