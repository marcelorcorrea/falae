Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  resources :roles
  resources :users do
    resources :spreadsheets
  end
end
