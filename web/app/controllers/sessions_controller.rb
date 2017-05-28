class SessionsController < ApplicationController
  def new
  end

  def create
    user = User.find_by(email: session_params[:email].downcase)
    if user && user.authenticate(session_params[:password])
      log_in user
      redirect_to user_spreadsheets_path(user) #, notice: 'You have successfully logged in.'
    else
      flash.now[:alert] = 'There is no match for this email and password.'
      render :new
    end
  end

  def destroy
    log_out
    redirect_to root_path
  end

  private
    def session_params
      params.require(:user).permit(:email, :password)
    end
end
