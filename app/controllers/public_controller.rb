class PublicController < ActionController::Base
  include Authentication

  layout "blog"

  before_action :set_blog

  private

    def set_blog
      @blog = Blog.find_by(subdomain: request.subdomain)
    end
end
