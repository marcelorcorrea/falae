Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  root 'sessions#new'
  get '/home', to: 'home#home'
  get '/about', to: 'home#about'
  get '/contact', to: 'home#contact'
  post '/csp-report', to: 'csp_reports#create'
  get '/login', to: 'sessions#new'
  post '/login', to: 'sessions#create'
  delete '/logout', to: 'sessions#destroy'

  resources :tours, only: [:index]

  resources :users, except: [:index, :destroy] do
    member do
      get 'photo'
      get 'change_email'
      get 'change_password'
      patch 'update_email'
      patch 'update_password'
    end
    resources :spreadsheets do
      resources :pages do
        resources :items do
          member do
            get 'image'
          end
        end
        member do
          get 'add_item'
          get 'search_item'
          post 'add_to_page'
          get 'edit_item'
          put 'update_item'
          delete 'remove_item'
          put 'swap_items'
        end
      end
    end
    resources :items do
      member do
        get 'image'
      end
    end
  end

  resources :account_activations, only: [:edit]
  resources :password_resets, only: [:new, :create, :edit, :update]
end
