Rails.application.routes.draw do
  root :to => 'home#index'
  devise_for :users, :controllers => {:sessions => "sessions", :registrations => "registrations", :passwords => "passwords"}
  devise_scope :user do
    get 'registrations/show_create_company', :to => "registrations#show_create_company"
    post 'registrations/create_company', :to => "registrations#create_company"
  end

  get 'under_construction' => 'mics#under_construction'

  resources :users, :only => [:edit, :update, :destroy] do
    collection do
      get :current
    end
    member do
      patch :add_existing_contact
    end
  end

  resources :company, :only => [:edit, :update] do
    collection do
      get :current
    end
  end

  resources :contacts do
    member do
      get :show_assign_to_company
      patch :assign_to_company
    end
    collection do
      get :clients
      get :vendors
      get :employees
    end
  end
end
