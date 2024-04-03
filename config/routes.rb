Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  match "auth/:provider/callback", to: "users/sessions#create", via: %i[ get post]
  delete "/sign-out", to: "users/sessions#destroy"

  resources :entries, only: %i[ show ]
  resource :micropub, only: %i[ create ], controller: "micropub"

  root "home#index"
end
