class Users::SessionsController < ApplicationController
  def create
    omniauth_provider = OmniauthProvider.create_with({
      user_attributes: {
        name: omniauth_params[:info][:name],
        email: omniauth_params[:info][:email]
      }
    })
    .find_or_create_by(
      provider: omniauth_params[:provider],
      uid: omniauth_params[:uid]
    )

    if omniauth_provider.persisted?
      session[:user_id] = omniauth_provider.user.id
    else
      flash[:alert] = omniauth_provider.errors.full_messages
    end

    redirect_to redirect_after_sign_in_path
  end

  def destroy
    session[:user_id] = nil

    redirect_to root_path
  end

  private

    def omniauth_data
      request.env["omniauth.auth"]
    end

    def omniauth_params
      {
        provider: omniauth_data[:provider],
        uid: omniauth_data[:uid],
        info: {
          name: omniauth_data[:info][:name],
          email: omniauth_data[:info][:email],
        }
      }
    end

    def redirect_after_sign_in_path
      request.env["omniauth.origin"] || root_path
    end
end
