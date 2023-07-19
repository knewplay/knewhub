Rails.application.routes.draw do
  resources :repositories, only: %i[index new create]
  get 'books/:owner/:name/*path', to: 'repositories#show'
  get 'books/:owner/:name', to: 'repositories#main'
  root 'repositories#index'

  namespace :webhooks do
    resource :github, controller: :github, only: [:create]
  end
end
