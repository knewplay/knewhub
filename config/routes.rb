Rails.application.routes.draw do
  root 'static_pages#index'

  scope module: 'author_dashboard', path: 'author', as: 'author_dashboard' do
    resources :repositories
    root 'repositories#index'
  end

  resources :repositories, only: [:update]

  post '/webhooks/github/:uuid', to: 'webhooks/github#create'

  get 'collections/:owner/:name/pages/index', to: 'collections#index'
  get 'collections/:owner/:name/pages/*path', to: 'collections#show'

  get 'auth/github/callback', to: 'auth/github#create'
  delete 'github_logout', to: 'auth/github#destroy'
end
