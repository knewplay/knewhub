require 'sidekiq/web'

Rails.application.routes.draw do
  # Static pages
  root 'static_pages#index'
  get 'collections/:author_username/:owner/:name/pages/index', to: 'collections#index'
  get 'collections/:author_username/:owner/:name/pages/*path', to: 'collections#show'
  get '/404', to: 'errors#not_found'
  get '/500', to: 'errors#internal_server_error'

  # Account creation and sessions
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

  namespace :webauthn do
    resources :credentials, only: %i[index create destroy] do
      post :options, on: :collection, as: 'options_for'
    end
    resource :authentication, controller: 'authentication', only: %i[new create] do
      post :options, on: :collection, as: 'options_for'
    end
  end
  get 'github/callback', to: 'auth/github#create'

  # User and Author settings
  namespace :settings do
    resource :account, only: [:show]
    resource :enable_author, controller: :enable_author, only: [:show]
    resource :author, only: %i[edit update]
    scope module: 'authors', path: 'author', as: 'author' do
      resources :repositories, except: [:show] do
        get :available, on: :collection
        resources :builds, only: [:index], controller: 'repositories/builds'
      end
    end

    root to: 'accounts#show'
  end

  # Answers and likes on collections pages
  scope '/questions/:question_id' do
    resources :answers, only: %i[index new create destroy]
  end
  resources :likes, only: %i[create destroy]

  # Administrator dashboard
  namespace :dashboard do
    resources :administrators, only: [:index]
    resources :authors, only: %i[index edit update]
    resources :autodesk_files, only: [:index, :show]
    resources :builds, only: %i[index show]
    resources :github_installations, only: [:index]
    resources :repositories, only: [:index]
    resources :users, only: [:index]
    root to: 'authors#index'
  end

  resources :repositories, only: [:update] do
    patch :toggle_banned_status, on: :member
  end

  constraints(Constraints::AdministratorRouteConstraint.new) do
    mount Sidekiq::Web => '/sidekiq'
  end

  # Webhooks
  post '/webhooks/github', to: 'webhooks/github#create'

  # Proxy
  get '/autodesk/viewer-proxy/derivativeservice/v2/:request_type/*path', to: 'proxy/autodesk#show'
end
