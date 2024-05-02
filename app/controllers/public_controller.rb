class PublicController < ActionController::Base
  include Authentication
  include SetBlog

  layout "blog"
end
