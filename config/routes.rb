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

  # Author dashboard
  scope module: 'author_admin', path: 'author', as: 'author_admin' do
    resources :repositories do
      post 'rebuild', on: :member
    end
    root 'repositories#index'
  end

  # Administrator dashboard
  namespace :system_admin do
    resources :authors
    resources :repositories

    root to: 'authors#index'
  end

  # Webhooks
  post '/webhooks/github/:uuid', to: 'webhooks/github#create'
end
