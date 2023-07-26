Rails.application.routes.draw do
  resources :repositories, only: %i[index new create]
  root 'repositories#index'

  post '/webhooks/github/:uuid', to: 'webhooks/github#create'

  get 'collections/:owner/:name/pages/index', to: 'collections#index'
  get 'collections/:owner/:name/pages/*path', to: 'collections#show'

  get 'auth/github/callback', to: 'auth/github#create'
  delete 'github_logout', to: 'auth/github#destroy'
end
