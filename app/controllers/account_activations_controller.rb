class AccountActivationsController < ApplicationController
  before_action :set_user

  def edit
    if valid_user_activation?
      @user.activate
      log_in @user
      flash[:success] = t('user_mailer.account_activation.activation')
      redirect_to user_spreadsheets_path(@user)
    else
      flash[:alert] = t('user_mailer.account_activation.invalid')
      redirect_to root_url
    end
  end

  private

  def set_user
    @user = User.find_by(email: params[:email])
  end

  def valid_user_activation?
    @user && !@user.activated? &&
      @user.authentic_token?(:activation, params[:id])
  end
end
