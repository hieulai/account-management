Rails.application.routes.draw do
  root :to => 'home#index'

  resources :users

  resources :contacts do
    resources :relationships
  end
end
