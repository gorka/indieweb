module BlogHelper
  def blog_url(url_func, blog)
    media_url_params = Current.blog.custom_domain.present? ?
      { host: Current.blog.custom_domain } :
      { subdomain: Current.blog.subdomain }

    send(url_func, media_url_params)
  end
end
