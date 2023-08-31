Rails.application.routes.draw do
  # Static pages
  root 'static_pages#index'
  get 'collections/:owner/:name/pages/index', to: 'collections#index'
  get 'collections/:owner/:name/pages/*path', to: 'collections#show'

  # Sign up and sessions
  devise_for :users, controllers: {
    confirmations: 'users/confirmations',
    registrations: 'users/registrations',
    sessions: 'users/sessions'
  }

  resources :administrators, only: %i[new create]
  namespace :sessions do
    resource :administrator, only: %i[new create destroy]
    resource :author, only: [:destroy]
  end
  get 'auth/github/callback', to: 'sessions/authors#create'

  namespace :webauthn do
    resources :credentials, only: %i[index create destroy] do
      post :options, on: :collection, as: 'options_for'
    end
    resource :authentication, controller: 'authentication', only: %i[new create] do
      post :options, on: :collection, as: 'options_for'
    end
  end

  # User and Author settings
  namespace :settings do
    resource :account, only: [:show]
    resource :enable_author, controller: :enable_author, only: [:show]
    resource :author, only: %i[edit update]
    scope module: 'authors', path: 'author', as: 'author' do
      resources :repositories, except: [:show]
    end

    root to: 'accounts#show'
  end

  # Administrator dashboard
  namespace :dashboard do
    resources :authors, only: %i[index edit update]
    resources :repositories, only: [:index]
    resources :administrators, only: [:index]
    root to: 'authors#index'
  end

  resources :repositories, only: [:update] do
    patch :toggle_banned_status, on: :member
  end

  # Webhooks
  post '/webhooks/github/:uuid', to: 'webhooks/github#create'
end
