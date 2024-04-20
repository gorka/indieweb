class PublicController < ActionController::Base
  layout "blog"

  before_action :set_blog

  before_action :log_domain

  private

    def set_blog
      @blog = Blog.find_by(subdomain: request.subdomain)
    end

    def log_domain
      logger.info("-> domain: #{request.host} & subdomain: #{request.subdomain}")
    end
end
