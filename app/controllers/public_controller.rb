class PublicController < ActionController::Base
  include Pagy::Backend
  include Authentication
  include SetBlog

  layout "blog"
end
