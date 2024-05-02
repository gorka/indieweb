class CustomDomainOrSubdomain
  def self.matches?(request)
    blog_with_custom_domain = Blog.find_by(custom_domain: request.host)
    return true if blog_with_custom_domain

    request.subdomain.present? && request.subdomain != "www"
  end
end

Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  match "auth/:provider/callback", to: "users/sessions#create", via: %i[ get post], as: :auth_callback
  delete "/sign-out", to: "users/sessions#destroy"

  resources :blogs, param: :subdomain

  constraints(CustomDomainOrSubdomain) do
    get "/", to: "public/blogs#show"
    resources :entries, only: %i[ show ], module: "public"
    resource :media, only: %i[ create ]
    resource :micropub, only: %i[ show create ], controller: "micropub", as: "micropub"
  end

  root "home#index"
end
