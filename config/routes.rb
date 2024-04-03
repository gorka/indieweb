Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  resources :entries, only: %i[ show ]
  resource :micropub, only: %i[ create ], controller: "micropub"

  root "home#index"
end
