Rails.application.routes.draw do
  resources :repositories, only: %i[index new create]
  root 'repositories#index'

  post '/webhooks/github/:uuid', to: 'webhooks/github#create'
end
