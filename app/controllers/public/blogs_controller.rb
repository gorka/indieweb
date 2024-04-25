class Public::BlogsController < PublicController
  def show
    # todo: simplify with pundit.
    if current_user == @blog.user
      @entries = @blog.entries
    else
      @entries = @blog.entries.where(status: "published")
    end
  end
end
