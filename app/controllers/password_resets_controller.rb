class PasswordResetsController < ApplicationController
  before_action :get_user, only: %i[edit update]
  before_action :valid_user_password_reset, only: %i[edit update]
  before_action :check_expiration, only: %i[edit update]

  def new
  end

  def create
    @user = User.find_by(email: params[:password_reset][:email].downcase)
    if @user&.activated?
      @user.create_reset_digest
      @user.send_password_reset_email
    end
    flash[:warning] = t('user_mailer.password_reset.verification')
    redirect_to root_url
  end

  def edit
  end

  def update
    if @user.update(user_params)
      log_in @user
      @user.update(reset_digest: nil)
      flash[:success] = t('user_mailer.password_reset.valid_reset')
      redirect_to user_spreadsheets_path(@user)
    else
      render 'edit'
    end
  end

  private

  def user_params
    params.require(:user).permit(:password, :password_confirmation)
  end

  def get_user
    @user = User.find_by(email: params[:email])
  end

  # Confirms a valid user.
  def valid_user_password_reset
    return unless !@user || !@user.activated? ||
      !@user.authentic_token?(:reset, params[:id])
    flash[:alert] = t('user_mailer.password_reset.invalid')
    redirect_to root_url
  end

  # Checks expiration of reset token.
  def check_expiration
    return unless @user.password_reset_expired?
    flash[:alert] = t('user_mailer.password_reset.expired_token')
    redirect_to new_password_reset_url
  end
end
