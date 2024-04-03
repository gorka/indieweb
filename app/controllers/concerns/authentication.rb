module Authentication
  extend ActiveSupport::Concern

  included do
    before_action :authenticate

    helper_method :current_user, :user_signed_in?
  end

  private

    def authenticate
      if authenticated_user = User.find_by(id: session[:user_id])
        Current.user = authenticated_user
      end
    end

    def current_user
      Current.user
    end

    def user_signed_in?
      current_user.present?
    end
end
