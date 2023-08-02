Rails.application.routes.draw do
  namespace :system_admin do
    resources :authors
    resources :repositories

    root to: 'authors#index'
  end

  root 'static_pages#index'

  scope module: 'author_admin', path: 'author', as: 'author_admin' do
    resources :repositories do
      post 'rebuild', on: :member
    end
    root 'repositories#index'
  end

  post '/webhooks/github/:uuid', to: 'webhooks/github#create'

  get 'collections/:owner/:name/pages/index', to: 'collections#index'
  get 'collections/:owner/:name/pages/*path', to: 'collections#show'

  get 'auth/github/callback', to: 'auth/github#create'
  delete 'github_logout', to: 'auth/github#destroy'
end
