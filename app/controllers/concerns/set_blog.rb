module SetBlog
  extend ActiveSupport::Concern

  included do
    before_action :set_blog
  end

  private

    def set_blog
      Current.blog = Micropub.get_blog_from_request(request)
    end
end
