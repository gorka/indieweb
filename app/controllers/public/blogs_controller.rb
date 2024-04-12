class Public::BlogsController < PublicController
  before_action :set_blog, only: %i[ show ]

  def show
  end

  private

    def set_blog
      @blog = Blog.find_by!(subdomain: request.subdomain)
    end
end
