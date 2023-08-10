Rails.application.routes.draw do
  # Static pages
  root 'static_pages#index'
  get 'collections/:owner/:name/pages/index', to: 'collections#index'
  get 'collections/:owner/:name/pages/*path', to: 'collections#show'

  # Sign up and sessions
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

  # Author dashboard
  scope module: 'author_dashboards', path: 'author', as: 'author_dashboards' do
    resources :repositories
    root 'repositories#index'
  end

  resources :repositories, only: [:update]

  # Administrator dashboard
  namespace :system_dashboards do
    resources :authors
    resources :repositories, except: %i[new create]
    resources :administrators, only: %i[index]
    root to: 'authors#index'
  end

  # Webhooks
  post '/webhooks/github/:uuid', to: 'webhooks/github#create'
end
