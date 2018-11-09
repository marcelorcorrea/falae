class SessionsController < ApplicationController
  def new
    redirect_to user_spreadsheets_path(current_user) if logged_in?
  end

  def create
    @user = User.find_by(email: session_params[:email].downcase)
    if @user&.authenticate(session_params[:password])
      if @user.activated?
        log_in @user
        respond_to do |format|
          format.html { redirect_to user_spreadsheets_path(@user) }
          format.json { render template: 'users/show', location: @user }
        end
      else
        flash.now[:warning] = t 'user_mailer.account_activation.notactivated'
        respond_to do |format|
          format.html { render :new }
          format.json { unauthorized_json_access }
        end
      end
    else
      flash.now[:alert] = t 'flash.error.wrong_email_password'
      respond_to do |format|
        format.html { render :new }
        format.json { unauthorized_json_access }
      end
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
