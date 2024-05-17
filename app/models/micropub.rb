class Micropub
  RESERVED_DOMAINS = [
    "example.com",
    "indieblog.xyz",
    "ngrok-free.app"
  ]

  MICROFORMAT_OBJECT_TYPES = {
    entry: {
      class: Entry,
      supported_properties: [
        "category",
        "content",
        "name",
        "photo",
        "post-status"
      ]
    }
  }.with_indifferent_access

  def self.resource_from_url(url)
    uri = URI.parse(url)

    return unless uri.path && uri.host

    controller_name, resource_id = uri.path.split("/").reject(&:empty?)

    blog = get_blog_from_host(uri.host)
    return unless blog

    microformat = MICROFORMAT_OBJECT_TYPES[controller_name.singularize.to_sym]
    return unless microformat

    microformat_class = microformat[:class]
    return unless microformat_class

    microformat_class.unscoped.find_by(blog: blog, id: resource_id)
  end

  def self.get_blog_from_request(request)
    blog_with_custom_domain = Blog.find_by(custom_domain: request.host)
    blog_with_custom_domain.present? ? blog_with_custom_domain : Blog.find_by(subdomain: request.subdomain)
  end

  def self.get_blog_from_host(host)
    blog_with_custom_domain = Blog.find_by(custom_domain: host)
    blog_with_custom_domain.present? ? blog_with_custom_domain : Blog.find_by(subdomain: extract_subdomain(host))
  end

  private

    def self.extract_subdomain(host)
      RESERVED_DOMAINS.each do |domain|
        if host.end_with?(domain)
          subdomain = host.chomp("." + domain)
          return subdomain unless subdomain.empty?
        end
      end

      nil
    end
end
