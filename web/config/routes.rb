Rails.application.routes.draw do
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