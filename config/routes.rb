Rails.application.routes.draw do
  resources :repositories, only: %i[index new create]
  root 'repositories#index'

  namespace :webhooks do
    resource :github, controller: :github, only: [:create]
  end
end
