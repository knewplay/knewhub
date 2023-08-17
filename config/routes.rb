Rails.application.routes.draw do
  root 'static_pages#index'

  scope module: 'author_dashboards', path: 'author', as: 'author_dashboards' do
    resources :repositories
    resources :authors, only: %i[edit update]
    root 'repositories#index'
  end

  resources :repositories, only: [:update]

  post '/webhooks/github/:uuid', to: 'webhooks/github#create'

  get 'collections/:owner/:name/pages/index', to: 'collections#index'
  get 'collections/:owner/:name/pages/*path', to: 'collections#show'

  get 'auth/github/callback', to: 'auth/github#create'
  delete 'github_logout', to: 'auth/github#destroy'
end
