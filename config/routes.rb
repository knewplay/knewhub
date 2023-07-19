Rails.application.routes.draw do
  resources :repositories, only: %i[index new create]
  get 'books/:owner/:name/*path', to: 'repositories#show'
  root 'repositories#index'

  namespace :webhooks do
    resource :github, controller: :github, only: [:create]
  end
end
