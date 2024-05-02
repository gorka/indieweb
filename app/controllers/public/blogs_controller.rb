class Public::BlogsController < PublicController
  def show
    # todo: simplify with pundit.
    if current_user == Current.blog.user
      @entries = Current.blog.entries
    else
      @entries = Current.blog.entries.where(status: "published")
    end
  end
end
