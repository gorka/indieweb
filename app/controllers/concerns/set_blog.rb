module SetBlog
  extend ActiveSupport::Concern

  included do
    before_action :set_blog

    helper_method :get_blog_from_url
  end

  RESERVED_DOMAINS = [
    "example.com",
    "indieblog.xyz",
    "ngrok-free.app"
  ]

  private

    def extract_subdomain(host)
      RESERVED_DOMAINS.each do |domain|
        if host.end_with?(domain)
          subdomain = host.chomp("." + domain)
          return subdomain unless subdomain.empty?
        end
      end

      nil
    end

    def get_blog_from_request(request)
      blog_with_custom_domain = Blog.find_by(custom_domain: request.host)
      blog_with_custom_domain ? blog_with_custom_domain : Blog.find_by(subdomain: request.subdomain)
    end

    def get_blog_from_host(host)
      subdomain = extract_subdomain(host)
      Blog.find_by(subdomain: request.subdomain)
    end

    def set_blog
      Current.blog = get_blog_from_request(request)
    end
end
