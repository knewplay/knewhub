Rails.application.routes.draw do
  resources :repositories, only: %i[index new create]
  root 'repositories#index'

  get 'collections/:owner/:name/pages/index', to: 'collections#index'
  get 'collections/:owner/:name/pages/*path', to: 'collections#show'

  namespace :webhooks do
    resource :github, controller: :github, only: [:create]
  end
end
