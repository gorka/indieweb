class BlogsController < ApplicationController
  before_action :set_blog, only: %i[ show edit update destroy ]

  def index
    @blogs = current_user.blogs
  end

  def show
  end

  def new
    @blog = current_user.blogs.new
  end

  def edit
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
    if @blog.update(blog_params)
      redirect_to @blog, notice: "Blog was successfully updated.", status: :see_other
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @blog.destroy!
    redirect_to blogs_url, notice: "Blog was successfully destroyed.", status: :see_other
  end

  private

    def set_blog
      @blog = Blog.find_by(subdomain: params[:subdomain])
    end

    def blog_params
      params.require(:blog).permit(:user_id, :title, :subdomain, :authorization_endpoint, :token_endpoint)
    end
end
