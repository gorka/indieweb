class Public::Blogs::SessionsController < PublicController
  skip_before_action :verify_password_protection

  def new
  end

  def create
    authorized_guest = Current.blog.authenticate(params[:password])

    if authorized_guest
      reset_session
      session[:authorized_guest] = "authorized_guest"
      redirect_to root_path
    else
      redirect_to blog_sign_in_path, alert: "Contraseña incorrecta"
    end
  end

  def destroy
    reset_session
    session[:authorized_guest] = nil
    redirect_to root_path, status: :see_other, notice: "Te has desconectado correctamente"
  end
end
