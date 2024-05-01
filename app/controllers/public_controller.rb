class PublicController < ActionController::Base
  include Authentication

  layout "blog"

  before_action :set_blog

  private

    def set_blog
      # todo: extract into Current.blog

      blog_with_custom_domain = Blog.find_by(custom_domain: request.host)

      @blog = blog_with_custom_domain ? blog_with_custom_domain : Blog.find_by(subdomain: request.subdomain)
    end
end
