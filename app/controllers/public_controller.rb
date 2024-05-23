class PublicController < ActionController::Base
  include Pagy::Backend
  include Authentication
  include SetBlog

  layout "blog"

  before_action :verify_password_protection

  private

    def verify_password_protection
      return unless Current.blog.password_protected?

      if session[:authorized_guest] != "authorized_guest"
        redirect_to blog_sign_in_path
      end
    end
end
