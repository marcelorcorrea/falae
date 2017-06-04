class SessionsController < ApplicationController

  def new
  end

  def create
    @user = User.find_by(email: session_params[:email].downcase)
    if @user && @user.authenticate(session_params[:password])
      log_in @user
      respond_to do |format|
        format.html { redirect_to user_spreadsheets_path(@user) }
        format.json {
          render template: 'users/show', location: @user
          log_out
        }
      end
    else
      flash.now[:alert] = t('flash.error.wrong_email_password')
      respond_to do |format|
        format.html { render :new }
        format.json { render json: {error: 'Unauthorized'}, status: :unauthorized }
      end
    end
  end

  def destroy
    log_out
    redirect_to root_path
  end

  private
    def session_params
      puts '*'*500
      puts params.inspect
      params.require(:user).permit(:email, :password)
    end
end
