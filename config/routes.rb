Rails.application.routes.draw do
  root 'static_pages#index'

  scope module: 'author_admin', path: 'author', as: 'author_admin' do
    resources :repositories
    root 'repositories#index'
  end

  post 'author_admin/repositories/:id/rebuild', to: 'author_admin/repositories#rebuild', as: 'rebuild_repository'

  post '/webhooks/github/:uuid', to: 'webhooks/github#create'

  get 'collections/:owner/:name/pages/index', to: 'collections#index'
  get 'collections/:owner/:name/pages/*path', to: 'collections#show'

  get 'auth/github/callback', to: 'auth/github#create'
  delete 'github_logout', to: 'auth/github#destroy'
end
