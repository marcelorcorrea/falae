Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  root 'sessions#new'
  get '/home', to: 'header_pages#home'
  get '/about', to: 'header_pages#about'
  get '/contact', to: 'header_pages#contact'
  post '/csp-report', to: 'csp_reports#create'
  get '/login', to: 'sessions#new'
  post '/login', to: 'sessions#create'
  delete '/logout', to: 'sessions#destroy'

  resources :users, except: [:index, :destroy] do
    member do
      get 'photo'
      get 'change_email'
      get 'change_password'
      get 'import_spreadsheet'
      post 'add_spreadsheet'
      patch 'update_email'
      patch 'update_password'
    end
    resources :spreadsheets do
      get 'export'
      get 'export_data'
      get 'import_page'
      post 'add_page'
      resources :pages do
        resources :items do
          member do
            get 'image'
          end
        end
        member do
          get 'add_item'
          get 'edit_item'
          get 'export'
          get 'export_data'
          get 'pdf'
          get 'search_item'
          post 'add_to_page'
          put 'swap_items'
          put 'update_item'
          delete 'remove_item'
        end
      end
    end
    resources :items do
      member do
        get 'image'
        get 'pdf'
      end
    end
  end

  resources :account_activations, only: [:edit]
  resources :password_resets, only: [:new, :create, :edit, :update]
end
