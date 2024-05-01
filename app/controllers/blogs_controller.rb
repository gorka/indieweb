class BlogsController < ApplicationController
  before_action :authorize
  before_action :set_blog, only: %i[ show edit update destroy ]

  def index
    @blogs = current_user.blogs
  end

  def show
    unless authorize_ownership
      redirect_to root_path, alert: "You're not authorized to perform the requested action."
      return
    end
  end

  def new
    @blog = current_user.blogs.new
  end

  def edit
    unless authorize_ownership
      redirect_to root_path, alert: "You're not authorized to perform the requested action."
      return
    end
  end

  def create
    @blog = current_user.blogs.new(blog_params)

    if @blog.save
      redirect_to @blog, notice: "Blog was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    unless authorize_ownership
      redirect_to root_path, alert: "You're not authorized to perform the requested action."
      return
    end

    if @blog.update(blog_params)
      redirect_to @blog, notice: "Blog was successfully updated.", status: :see_other
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    unless authorize_ownership
      redirect_to root_path, alert: "You're not authorized to perform the requested action."
      return
    end

    @blog.destroy!
    redirect_to blogs_url, notice: "Blog was successfully destroyed.", status: :see_other
  end

  private

    def authorize
      if !current_user
        redirect_to root_path, alert: "You're not authorized to perform the requested action."
        return
      end
    end

    def authorize_ownership
      @blog.user == current_user
    end

    def set_blog
      @blog = Blog.find_by(subdomain: params[:subdomain])
    end

    def blog_params
      params.require(:blog).permit(:user_id, :title, :subdomain, :custom_domain, :authorization_endpoint, :token_endpoint)
    end
end
