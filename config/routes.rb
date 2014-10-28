Rails.application.routes.draw do
  devise_for :users, :controllers => { :sessions => "sessions", :registrations => "registrations", :passwords => "passwords" }
  root :to => 'home#index'

  get 'under_construction' => 'mics#under_construction'

  resources :users do
    member do
      patch :add_existing_contact
    end
  end

  resources :contacts do
    collection do
      get :clients
      get :vendors
      get :employees
    end
  end



end
