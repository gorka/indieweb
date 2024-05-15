class Public::BlogsController < PublicController
  def show
    # todo: simplify with pundit.
    if current_user == Current.blog.user
      entries = Current.blog.entries
    else
      entries = Current.blog.entries.where(status: "published")
    end

    entries = entries.includes(:categories, photos_with_alt: { photo_attachment: :blob }).strict_loading

    @pagy, @entries = pagy(entries)
  end
end
