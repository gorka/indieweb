class Subdomain
  def self.matches?(request)
    request.subdomain.present? && request.subdomain != "www"
  end
end

Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  match "auth/:provider/callback", to: "users/sessions#create", via: %i[ get post], as: :auth_callback
  delete "/sign-out", to: "users/sessions#destroy"

  resources :blogs, param: :subdomain

  constraints(Subdomain) do
    get "/", to: "public/blogs#show"
    resources :entries, only: %i[ show ], module: "public"
    resource :micropub, only: %i[ create ], controller: "micropub", as: "micropub"
  end

  root "home#index"
end
