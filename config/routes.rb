Rails.application.routes.draw do
  resources :repositories, only: %i[index new create]
  root 'repositories#index'
end
